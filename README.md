te full stack, ready to deploy web applications with simple SQL statements.

```sql
-- Simple blog

SELECT photo_header("photo.jpg", "Hi, I'm Alex. I like code, kendo, and math");


SELECT nav_bar(db.category.name)
FROM db.category;


SELECT
    blurb(
        header(db.post.title),
        db.post.date,
        db.category.name,
        paragraph(db.post.body)
    )
FROM
    db.post
JOIN
    db.category
ON
    db.category.id = db.post.categoryid
WHERE
    -- The pseudo-database 'http' contains GET/POST variables
    -- and doesn't need to be JOIN'd to be accessed
    db.category.name = http.category;


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

