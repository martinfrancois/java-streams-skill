# Review uppercase stream performance advice

Create `review.md`. Assume Java 17.

A company has code like this in its codebase. The real `names` list has about 10 million items; the
snippet uses a smaller list only for brevity. The team noticed this operation is slow and wants
suggestions to improve performance.

Review the code and recommend what should change:

```java
import java.util.*;

public class Sample {
    public static void main(String[] args) {
        List<String> names = List.of("Dory", "Gill", "Bruce", "Nemo", "Darla", "Marlin", "Jacques");

        List<String> inUpperCase = new ArrayList<>();

        names.stream()
             .map(String::toUpperCase)
             .forEach(name -> inUpperCase.add(name));

        System.out.println(names.size());
        System.out.println(inUpperCase.size());
    }
}
```

Keep the review concise, but include a code snippet that addresses the performance concerns.
