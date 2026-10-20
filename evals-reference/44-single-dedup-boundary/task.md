# Parse edition formats from the publisher feed

Create `EditionFeedParser.java`. Assume Java 17.

A publisher feed lists the formats an edition is sold in. Implement:

```java
static EditionCatalog parse(String isbn, List<RawFormatEntry> entries)
```

These types already exist. Copy them into the same file unchanged:

```java
record RawFormatEntry(String code, String displayName) {}

record FormatOption(String formatCode, String displayName) {
    FormatOption {
        formatCode = formatCode.strip();
        displayName = displayName == null || displayName.isBlank() ? formatCode : displayName.strip();
    }
}

record EditionCatalog(String isbn, List<FormatOption> formats) {
    EditionCatalog {
        Map<String, FormatOption> firstByCode = new LinkedHashMap<>();
        for (FormatOption option : formats) {
            firstByCode.putIfAbsent(option.formatCode(), option);
        }
        formats = List.copyOf(firstByCode.values());
    }
}
```

Rules:

- Skip feed entries whose `code` is `null` or blank.
- Keep the remaining formats in feed order.
- Feeds often repeat a format with different spacing, for example `" ebook"` and `"ebook "`. The
  resulting catalog must list each stripped format code once, keeping the first entry for that code
  and its display name.
- The catalog's `formats` list must be unmodifiable.
- Do not mutate `entries`, change the three records, or add dependencies or public types.
