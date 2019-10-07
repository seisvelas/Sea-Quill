#lang racket

(require web-server/servlet)  ; Provides dispatch-rules.
; Provides serve/servlet and happens to provide response/full.
(require web-server/servlet-env)

(define (http-response content)  ; The 'content' parameter should be a string.
  (response/full
    200                  ; HTTP response code.
    #"OK"                ; HTTP response message.
    (current-seconds)    ; Timestamp.
    TEXT/HTML-MIME-TYPE  ; MIME type for content.
    '()                  ; Additional HTTP headers.
    (list                ; Content (in bytes) to send to the browser.
      (string->bytes/utf-8 content))))

(define (request-handler request)
  (display (request-bindings request))
  (http-response "<h1>This is the first page!</h1>"))

(serve/servlet
  request-handler
  #:launch-browser? #t
  #:quit? #f
  #:listen-ip "127.0.0.1"
  #:port 8000
  #:servlet-regexp #rx"")