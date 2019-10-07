#lang br/quicklang
(require "grammar.rkt")

(define (read-syntax path port)
  (define parse-tree (parse path (make-tokenizer port)))
  (define module-datum `(module sql-mod "expander.rkt"
                          ,parse-tree))
  (datum->syntax #f module-datum))
(provide read-syntax)

; I think I can implement JOIN by using TRIM
; with from/stop-before to get the first field 
(require brag/support)
(define (make-tokenizer port)
  (define (next-token)
    (define bf-lexer
      (lexer
       [whitespace (token lexeme #:skip? #t)]
       [(:or "select" "from" "join" "on" "where" "," "and" "=" "(" ")" ";") lexeme]
       [(:+ (:or alphabetic "." "\"")) (token 'WORD lexeme)]
       [(:+ numeric) (token 'WORD lexeme)]))
    (bf-lexer port))  
  next-token)