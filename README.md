Create full stack, ready to deploy web applications with a single query.

```sql
-- 4chan style imageboard
SELECT 
  navbar(db.boards)
  banner_image(banner.jpg)
  form(text, image INTO db.posts)
  forum(db.posts)
  footer("Copyleft Alex V 2019")
FROM http
JOIN db on http.user=db.user
```

Sea Quill is not even beta yet. Don't run Sea Quill on any server you aren't comfortable publically publishing the root credentials to.

## Todo:

- [ ] Expander with mock data (`select` macro)
- [ ] Functions (for frontend JS features!)
- [ ] Beautiful CSS tables for pure tabular data (no frontend functions)
- [ ] Working with Racker web server libs
- [ ] Work with Racket SQL lib (use Racquel so I can be cross platform?)

