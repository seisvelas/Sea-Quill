#lang reader "reader.rkt"

create table post (title TEXT, content TEXT)

insert into post (title, content) values (request.title, request.content)

select title, content
from post

select name, pass
from request

