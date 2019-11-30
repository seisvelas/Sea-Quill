#lang brag
; Interesting that comments are (basically) the same in Brag and Racket,
; but Racket style #| block comments |# don't work across multiple lines
; in Brag. 
; I wonder to what extent Brag's reader is just Racket's reader.
; Anyway,

; TODO:
; statement : select | insert | update | delete
; aggregation : "group by" ...
; comments (should be removed by tokenizer)

program      : (@statement)*
statement    : create_table | select | insert
insert       : /"insert" /"into" @source /"(" fields /")" /"values" /"(" fields /")"
create_table : /"create" /"table" @source /"(" field_types /")"
field_types  : @field @type (/"," @field @type)*
type         : WORD
select       : /"select" fields (/"from" source joins? where?)? /";"?
fields       : @field (/"," @field)*
field        : STRING | WORD | function
function     : WORD /"(" @fields* /")"
source       : WORD
joins        : join* 
join         : /"join" source /"on" condition
where        : "where" condition (("and" | "or") condition)*
condition    : (field | INTEGER) /"=" (field | INTEGER)