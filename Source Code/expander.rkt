#lang br/quicklang

(require threading) ; Elixir piping (threading macros in Racket-speak)
(require syntax/parse/define)
(require web-server/servlet)  ; Provides dispatch-rules.
; Provides serve/servlet and happens to provide response/full.
(require web-server/servlet-env)
(require racket/cmdline)
(require db)

(define HTTP.request (make-parameter null))
(define namespace (make-parameter null))

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


(define (load-table table)
  (table->dict (query (postgresql-connect #:user "sea"
                                   #:database "sea"
                                   #:password "quill")
              (string-append "select * from " table))))


(define (get-table-data source)
  (cond [(equal? source "request") (HTTP.request)]
        [else (load-table source)])) 

(define (sql-func func . fields)


(define (resolve-field field source)
  (if (list? field)
      (cond [(equal? (first field) 'function) (apply sql-func field)]
            [else "Invalid function call"])
      (let ((numeric (string->number field)))
        (cond [numeric field] ; if it's a number return as is
              [(and (string-prefix? field "\"") (string-suffix? field "\"")) field]
              [else (hash-ref (get-table-data source) field (string-append "No such field: " field))]))))

(define-simple-macro (select . clauses)
  (let [(fields (first 'clauses))
        (source (if (> (length 'clauses) 1) (second (second 'clauses)) '()))
        ] ; add joins and filters here! (then add them below duh)
    (map (lambda (field) (resolve-field field source)) (rest fields)))) ; then just get the colums in fields :D
(provide select)

(define (program . code)
  (filter (lambda (x) (not (void? x))) code))
(provide program)

(define (format-creation-fields fields [string-fields ""])
  (if (empty? fields)
      string-fields
      (format-creation-fields (cddr fields)
        (string-append string-fields
          (if (equal? "" string-fields) "" ", ")
          (car fields) " " (cadr fields)))))

(define-simple-macro (create table fields)
  (query-exec (postgresql-connect #:user "sea"
                                  #:database "sea"
                                  #:password "quill")
    (format "CREATE TABLE IF NOT EXISTS ~a (~a)"
            table
            (format-creation-fields (cdr 'fields)))))
(provide create)

(define (resolve x)
  (if (equal? (first (string-split x ".")) "request")
    (hash-ref (HTTP.request) (second (string-split x ".")) (void))
    x))

(define-simple-macro (insert table fields values)
  (let ((http-vals (map (lambda (x) (resolve x)) (rest 'values))))
    (if (member (void) http-vals)
        (void)
        (let ((statement (format "INSERT INTO ~a (~a) VALUES (~a)" table
          (string-join (rest 'fields) ", ")
          (string-join (map (lambda (field) (string-append "'" field "'"))
               http-vals) ", "))))
            (query-exec (postgresql-connect #:user "sea"
                                   #:database "sea"
                                   #:password "quill")
                    statement))))) ; check for void cuz that means no insert-y!
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
       (http-response (~a response)))

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
