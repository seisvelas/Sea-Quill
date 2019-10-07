#lang br/quicklang
(require "grammar.rkt")

(require brag/support)
(define (make-tokenizer port)
  (define (next-token)
    (define bf-lexer
      (lexer
       [whitespace (token lexeme #:skip? #t)]
       [(:or "select" "from" "join" "on" "where" "and") lexeme]
       [(:+ alphabetic) (token 'WORD lexeme)]))
    (bf-lexer port))  
  next-token)


(define another-stx (parse (make-tokenizer (open-input-string "select thing from table"))))

(syntax->datum another-stx)