#lang brag
; Interesting that comments are (basically) the same in Brag and Racket,
; but Racket style #| block comments |# don't work across multiple lines
; in Brag. 
; I wonder to what extent Brag's reader is just Racket's reader.
; Anyway,

; TODO:
; statement : select | insert | update | delete
; aggregation : "group by" ...
; comments (should be removed by tokenizer
 
select    : /"select" fields /"from" source joins* filters*
fields    : @field (/"," @field)*
field     : WORD
source    : WORD
joins     : join* 
join      : "join" source /"on" condition
filters   : "where" condition ("and" | "or" condition)*
condition : (field | INTEGER) /"=" (field | INTEGER)