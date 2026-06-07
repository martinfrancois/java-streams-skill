# Implement session roster indexes

Create `SessionRosterIndexes.java`. Assume Java 17.

Implement:

```java
Map<String, List<String>> optedInEmailsByTrack(List<Conference> conferences)
Map<String, Session> longestSessionByRoom(List<Conference> conferences)
boolean hasWaitlistedRegistration(List<Conference> conferences)
```

Rules:

- `optedInEmailsByTrack` returns a map from non-null track name to attendee emails from sessions in
  that track.
- Include only registrations where `Registration::optedIn` is true.
- Ignore registrations with a null email.
- Each track's email list must be sorted alphabetically and must not contain duplicate emails.
- `longestSessionByRoom` ignores sessions with a null room.
- If several sessions use the same room, keep the session with the largest `minutes` value.
- If two sessions in the same room have the same `minutes` value, keep the earlier session in input
  encounter order.
- `hasWaitlistedRegistration` returns true when any registration is waitlisted.
- Do not add external dependencies, caching, background workers, or new public APIs.

Use these nested records:

```java
record Conference(List<Session> sessions) {}
record Session(
        String id,
        String room,
        String track,
        int minutes,
        List<Registration> registrations) {}
record Registration(String email, boolean optedIn, boolean waitlisted) {}
```
