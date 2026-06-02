# Implement training and packet helpers

Create `TrainingAndPackets.java`. Assume Java 17.

Implement two methods:

```java
Set<String> developerEmailsWithoutCompletedTraining(List<Company> companies)
List<Packet> packetsBeforeFirstLossSpike(List<Packet> packets, double threshold)
```

Rules:

- Companies contain mixed employee types.
- Only developers have secure-coding training records.
- Return the email of each developer whose training is not completed.
- The email result should be a set.
- `packetsBeforeFirstLossSpike` receives packets in chronological order.
- Return the chronological prefix before the first packet whose `loss` is greater than `threshold`.
- A later packet below the threshold must not be included after a spike has occurred.

Use these nested types:

```java
interface Employee {}
record Developer(String email, SecureCodingTraining secureCodingTraining) implements Employee {}
record Manager(String email) implements Employee {}
record SecureCodingTraining(boolean completed) {}
record Company(List<Employee> employees) {}
record Packet(long sequence, double loss) {}
```
