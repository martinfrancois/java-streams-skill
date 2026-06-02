# Write first-pass output routing

Assume Java 17.

Use `$java-optionals` to create `DeliveryRouter.java`.

Implement:

```java
void route(Optional<URI> webhook, Message message)
```

Rules:

- If `webhook` is present, call `sendWebhook(webhookUri, message)`.
- If `webhook` is absent, call `enqueueLocal(message)`.

Include these members:

```java
void sendWebhook(URI webhookUri, Message message) {}
void enqueueLocal(Message message) {}
record Message(String body) {}
```
