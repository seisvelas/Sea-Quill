#lang br/quicklang

(require threading) ; Elixir piping (threading macros in Racket-speak)
(require syntax/parse/define)
(require web-server/servlet)  ; Provides dispatch-rules.
; Provides serve/servlet and happens to provide response/full.
(require web-server/servlet-env)
(require racket/cmdline)
(require db)

(define HEADER #<<here-string-delimiter
<head>
<!-- Import jQuery and Bootstrap CSS/JS -->

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/css/bootstrap.min.css">
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/js/bootstrap.min.js"></script>

</head>
<body>
here-string-delimiter
)

(define FOOTER "</body></html>")
(define HTTP.request (make-parameter null))
(define SQL.functions (make-hash
  (list
    (cons "blog_post" (lambda (source filter title content) 
      (apply string-append 
             (map (lambda (name post)
                    (string-append "<div class='col-md-6 col-md-offset-3 jumbotron'><h1>" name "</h1><p>" post "</p></div></div>"
                    )) 
                  (resolve-field title source filter)
                  (resolve-field content source filter)))))
  )
))

(define (table->dict head [rows '()] [fields (make-immutable-hash)])
  (if (rows-result? head)
      (table->dict (rows-result-headers head) 
                   (map vector->list (rows-result-rows head)))
      (if (empty? head)
          fields
          (table->dict (rest head)
                       (map rest rows)
                       (hash-set fields (cdr (car (first head)))
                                 (flatten (map first rows)))))))


(define (load-table table filter)
  (table->dict (query (postgresql-connect #:user "sea"
                                   #:database "sea"
                                   #:password "quill")
              (string-append "select * from " table filter))))


(define (get-table-data source filter)
  (cond [(equal? source "request") (HTTP.request)]
        [else (load-table source filter)])) 

(define (sql-func source filter func . fields)
  (apply (hash-ref SQL.functions func "function not found") (cons source (cons filter fields))))

(define (resolve-field field source filter)
  (if (list? field)
      (cond [(equal? (first field) 'function) 
              (apply sql-func (cons source (cons filter (rest field))))]
            [else "Invalid function call"])
      (let ((numeric (string->number field)))
        (cond [numeric field] ; if it's a number return as is
              [(and (string-prefix? field "\"") (string-suffix? field "\"")) field]
              [(equal? (first (string-split field ".")) "request")
                (hash-ref (HTTP.request) (second (string-split field ".")) (void))]
              [else (hash-ref (get-table-data source filter) field (string-append "No such field: " field))]))))

(define (format-conditions conds)
  (string-append " where " (string-join (map (lambda (cond)
    (string-append (~a 
        (resolve (second (cadr cond)))
    ) "=" 
        (resolve (cadr (third cond)))))
    conds) 
  " and ")))

(define (get-filter clauses)
  (cond [(empty? clauses) ""]
        [(and (list? (first clauses)) 
              (not (empty? (first clauses)))
              (equal? (first (first clauses)) 'where))
            (let ((filter (first clauses)))
              (format-conditions (rest filter))
            )
        ]
        [else (get-filter (rest clauses))]))

(define-simple-macro (select . clauses)
  (let [(fields (first 'clauses))
        (source (if (> (length 'clauses) 1) (second (second 'clauses)) '()))
        (order #f)
        (filter (get-filter 'clauses))
        ] ; add joins here! (then add them below duh)
    (string-join (map (lambda (field) (resolve-field field source filter)) (rest fields)) ""))) ; then just get the colums in fields :D
(provide select)

(define (program . code)
  (filter (lambda (x) (not (or (empty? x) (void? x)))) code))
(provide program)

(define (format-creation-fields fields [string-fields ""])
  (if (empty? fields)
      string-fields
      (format-creation-fields (cddr fields)
        (string-append string-fields
          (if (equal? "" string-fields) "" ", ")
          (car fields) " " (cadr fields)))))

(define-simple-macro (create_table table fields)
  (query-exec (postgresql-connect #:user "sea"
                                  #:database "sea"
                                  #:password "quill")
    (format "CREATE TABLE IF NOT EXISTS ~a (~a)"
            table
            (format-creation-fields (cdr 'fields)))))
(provide create_table)

(define (resolve x)
  (if (equal? (first (string-split x ".")) "request")
    (string-append "'" (let ((result (hash-ref (HTTP.request) (second (string-split x ".")) (void))))
      (if (void? result) "#:void" result)) 
    "'")
    x))

(define (upload-form fields)
  (string-append "<form>"
  (apply string-append
        
         (map (lambda (field)
                (if (list? field)
                    (cond [(equal? "textarea" (second field))
              (string-append "<div class='form-group col-md-6 col-md-offset-3'>
                <label>" (last field) "</label>
                <textarea class='form-control' name='" (last field) "' placeholder='" (last field) "' rows='3'></textarea>
               </div>")
                      ])
                    
                    (string-append
                      "<div class='form-group col-md-6 col-md-offset-3'>
            <label>" field "</label>
            <input type='text' class='form-control' name='" field "' placeholder='" field "'>
          </div>"
                    )))
              fields))
              "  <button style='margin-bottom: 5%' type='submit' class='btn btn-primary col-md-4 col-md-offset-4'>Submit</button>"
              "</form>"
              ))

(define (quit-type field)
  (if (list? field) (last field) field)
  ; check if the field is a function. If so,
  ; remove the function info and just return the
  ; field name.
)

(define-simple-macro (insert table fields_raw values)
  (begin
  (let ((fields (map quit-type 'fields_raw))
        (http-vals (map (lambda (x) (resolve x)) (rest 'values))))
    (if (member "'#:void'" http-vals)
        (void)
        (let ((statement (format "INSERT INTO ~a (~a) VALUES (~a)" table
          (string-join (rest fields) ", ")
          (string-join http-vals ", "))))
            (query-exec (postgresql-connect 
                                   #:user "sea"
                                   #:database "sea"
                                   #:password "quill")
                    statement
            )
          )
      )
  )
  (upload-form (rest 'fields_raw)))
) ; check for void cuz that means no insert-y!
(provide insert)

(define-macro (bf-module-begin PARSE-TREE)
  #'(#%module-begin
     
     (define (http-response content)  ; The 'content' parameter should be a string.
       (response/full
        200                  ; HTTP response code.
        #"OK"                ; HTTP response message.
        (current-seconds)    ; Timestamp.
        TEXT/HTML-MIME-TYPE  ; MIME type for content.
        '()                  ; Additional HTTP headers.
        (list                ; Content (in bytes) to send to the browser.
         (string->bytes/utf-8 content))))

     (define (request-handler request response)
       (http-response (~a HEADER response FOOTER)))

     (define filename 
             (~> (find-system-path 'run-file)
                 path->complete-path
                 path->string
                 (string-split "/")
                 last))

     (display filename)

     (serve/servlet
      (λ (request)
        (let* [(vars (request-bindings request))
               (vars-hash (make-hash (map (lambda (x)
                                            (cons (~a (car x))   ; this cons hack is cuz the variables come as atoms
                                                  (~a (cdr x)))) ; but Sea Quill is all strings (and numbers I guess but haven't tried that yet)
                                          vars)))]
          (request-handler request (parameterize ((HTTP.request vars-hash))
                                     PARSE-TREE))))
      #:launch-browser? #f
      #:quit? #f
      #:listen-ip "127.0.0.1"
      #:port (string->number (vector-ref (current-command-line-arguments) 0))
      #:servlet-path (string-append "/" filename))))
(provide (rename-out [bf-module-begin #%module-begin]))
