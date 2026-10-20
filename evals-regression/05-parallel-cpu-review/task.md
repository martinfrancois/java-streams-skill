# Review CPU-heavy parallel stream

Use `$java-streams` to create `review.md`. Assume Java 17.

Review whether this parallel stream is reasonable and what caveats should be documented:

```java
import java.util.stream.LongStream;

final class HeavyComputation {
    long compute() {
        return LongStream.rangeClosed(1, 100_000)
                .parallel()
                .map(this::heavyComputation)
                .sum();
    }

    private long heavyComputation(long number) {
        long result = 0;
        for (int i = 0; i < 1000; i++) {
            result += (long) Math.sqrt(number * i);
        }
        return result;
    }
}
```
