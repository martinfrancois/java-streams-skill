# Simplify the newsroom feed planner

Create `NewsroomFeedPlanner.java` with the revised class. Assume Java 17.

The newsroom tooling team is sweeping old code. The planner below works; simplify its two methods
where that makes them clearer, and keep their behavior.

```java
import java.net.URI;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;

final class NewsroomFeedPlanner {
    private final List<DraftStory> drafts;
    private final Optional<String> extraFeedsVariable;
    NewsroomFeedPlanner(List<DraftStory> drafts, Optional<String> extraFeedsVariable) {
        this.drafts = drafts;
        this.extraFeedsVariable = extraFeedsVariable;
    }

    List<URI> syndicationFeeds(List<String> configuredFeeds) {
        List<URI> feeds = new ArrayList<>();
        configuredFeeds.stream().map(URI::create).forEach(feeds::add);
        extraFeedsVariable.stream()
                .flatMap(value -> Arrays.stream(value.split(",")))
                .map(String::trim)
                .filter(value -> !value.isBlank())
                .map(URI::create)
                .forEach(feeds::add);
        return feeds.stream().distinct().toList();
    }

    Map<String, Integer> openDraftsByDesk() {
        Map<String, Integer> counts = new HashMap<>();
        drafts.stream()
                .filter(draft -> !draft.published())
                .map(draft -> draft.desk().strip().toLowerCase(Locale.ROOT))
                .forEach(desk -> counts.merge(desk, 1, Integer::sum));
        return counts;
    }

    record DraftStory(String headline, String desk, boolean published) {}
}
```

Rules:

- `syndicationFeeds` lists configured feeds before feeds from the environment variable. When a
  feed appears more than once, keep only its first position. Callers only read this list.
- `openDraftsByDesk` counts unpublished drafts per normalized desk name. Several drafts share a
  desk. Callers add their own entries to the returned map afterwards, so it must stay a mutable
  `HashMap`.
- Keep the constructor, the method signatures, and `DraftStory` unchanged.
