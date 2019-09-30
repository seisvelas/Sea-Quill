#lang br/quicklang

(define-macro (bf-module-begin PARSE-TREE)
  #'(#%module-begin
     'PARSE-TREE))
(provide (rename-out [bf-module-begin #%module-begin]))

