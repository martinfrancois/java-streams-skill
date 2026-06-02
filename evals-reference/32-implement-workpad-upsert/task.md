# Implement workpad upsert

Assume Java 17.

Use `$java-optionals` to create `WorkpadService.java`.

Implement a small service that updates an existing workpad comment on a card, or creates one when
none exists.

Required API:

```java
Result upsertWorkpad(Card card, String text)
```

Rules:

- A workpad comment is any comment whose `text()` starts with `"<!-- workpad -->"`.
- If a workpad comment exists and its `id()` is `null` or blank, return `Result.failure("missing_action_id")`.
- If a workpad comment exists and has an id, return `Result.success("updated:" + id + ":" + text)`.
- If no workpad comment exists and `card.comments().size() >= 1000`, return `Result.failure("comment_window_incomplete")`.
- If no workpad comment exists and the comment window is not full, return `Result.success("created:" + card.id() + ":" + text)`.
- The create path must not run when an existing workpad comment is present.

Include these records:

```java
record Card(String id, List<Comment> comments) {}
record Comment(String id, String text) {}
record Result(boolean ok, String status) {
    static Result success(String status) { return new Result(true, status); }
    static Result failure(String status) { return new Result(false, status); }
}
```

