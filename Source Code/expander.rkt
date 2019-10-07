#lang br/quicklang

(require syntax/parse/define)
(require web-server/servlet)  ; Provides dispatch-rules.
; Provides serve/servlet and happens to provide response/full.
(require web-server/servlet-env)

(define HTTP.request (make-parameter null))

(define (get-table-data source)
  (if (equal? source "HTTP.request")
      (HTTP.request)

      ; Here I get a hash of the db stuff they requested (doesn't exist yet ofc)
      source)) ;'())) 

(define-simple-macro (select . clauses)
  (let [(fields (first 'clauses))
        (source (if (> (length 'clauses) 1) (second (second 'clauses)) '()))]
    (map (λ (field)
             (let ((numeric (string->number field)))
               (cond [numeric field] ; if it's a number return as is
                     [(and (string-prefix? field "\"") (string-suffix? field "\""))]
                     [else (hash-ref! (get-table-data source) field "")])))
         (rest fields)))) ; then just get the colums in fields :D
(provide select)

(define (program . code)
  code)
(provide program)

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

(serve/servlet
 (λ (request)
   (let* [(vars (request-bindings request))
          (vars-hash (make-hash (map (lambda (x)
                                       (cons (~a (car x))   ; this cons hack is cuz the variables come as atoms
                                             (~a (cdr x)))) ; but Sea Quill is all strings (and numbers I guess but haven't tried that yet)
                                     vars)))]
     (request-handler request (parameterize ((HTTP.request vars-hash))
                                PARSE-TREE))))
  #:launch-browser? #t
  #:quit? #f
  #:listen-ip "127.0.0.1"
  #:port 8000
  #:servlet-regexp #rx"")

     
     ))
(provide (rename-out [bf-module-begin #%module-begin]))

