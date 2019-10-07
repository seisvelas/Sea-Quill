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

## Todo:

#### Parser
- [x] Parse basic `select`s
- [x] `join on`s and filters (`where`s)
- [x] Parse frontend functions
- [x] Multiple statements (prevents monster queries)

#### Expander
- [x] `(select ...)` handler macro
- [ ] Get basic selects from http query vars working
- [ ] Database access
- [ ] Frontend functions expand to HTML

#### Features
- [ ] Grouping
- [ ] Make site


## Ideas

* Preserve the builtin row/grid nature of SQL, but add frontend functions to alter formatting if desired.
* Have a `gist()` frontend function for gists

