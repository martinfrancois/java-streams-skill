# Implement high-volume uppercase names

Create `UppercaseNames.java`. Assume Java 17.

Implement:

```java
List<String> uppercaseNames(List<String> names)
```

The production `names` list can contain 10 million items or more, so the implementation needs to
have good performance. For brevity, use this smaller list only as a placeholder example of the input:

```java
List<String> names = List.of("Dory", "Gill", "Bruce", "Nemo", "Darla", "Marlin", "Jacques");
```

Rules:

- Return a list containing each name converted with `String::toUpperCase`.
- Preserve the encounter order of `names`.
- Do not mutate the input list.
- Do not add external dependencies, background workers, caching, or new public APIs.
