#lang reader "reader.rkt"

create table post (title TEXT, content TEXT)

insert into post (title, textarea(content)) 
values (request.title, request.content)

select blog_post(title, content)
from post
where title=request.title
