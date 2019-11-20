Write full stack, ready to deploy web applications with simple SQL statements.

Sea Quill is still not ready, but it can already do some simple things. For example, here is a simple BBS message board in Sea Quill:

```sql
CREATE TABLE posts (title TEXT, content TEXT)

INSERT INTO posts (title, content) VALUES (request.title, request.content)

SELECT title, content FROM posts
```

That's it! Of course, there's still a long way to go! Here's what I'm still working on:

## Todo

#### Infrastructure

- [x] Compiler
- [x] Server
- [x] Database
- [x] INSERT
- [x] CREATE TABLE
- [x] SELECT
- [ ] WHERE
- [ ] JOIN
- [ ] Frontend Functions

## Musings

* Preserve the builtin row/grid nature of SQL, but add frontend functions to alter formatting if desired.
* Have a `gist()` frontend function for gists

