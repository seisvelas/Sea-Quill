te full stack, ready to deploy web applications with simple SQL statements.

For example, here is a simple chan-style message board in [x] lines

```sql
-- get posts



SELECT footer("All Code and Content Public Domain");
```

Sea Quill is not even beta yet. Don't run Sea Quill on any server you wouldn't publically publishing the root credentials to.

## Todo

#### Infrastructure

- [x] Compiler
- [x] Server
- [ ] Database
- [ ] HTML output (currently outputs Lisp sexprs)

#### Language
- [x] `(select ... from)` macro
- [ ] Filtering (`where`) 
- [ ] Joins
- [ ] Frontend Functions
- [ ] Grouping (group by)

## Musings

* Preserve the builtin row/grid nature of SQL, but add frontend functions to alter formatting if desired.
* Have a `gist()` frontend function for gists

