# Speed up complaint extraction from guest reviews

Create `GuestComplaintExtractor.java` with the revised class. Assume Java 21.

The hotel back office collects complaints from guest reviews. A complaint is any line in the review
title, the review body, or a staff reply that starts with a complaint label. The class below works,
but a colleague wondered whether a Java 21 codebase should write it this way, for readability and
speed. Rewrite it to be clearer and faster where you can, with any API Java 21 offers, and keep what
it does.

```java
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

final class GuestComplaintExtractor {
    private static final Pattern COMPLAINT_LINE = Pattern.compile("(?i)^[\\t ]*(urgent[\\t ]+complaint|complaint)[\\t ]*:[\\t ]*(.*)$");

    static List<Complaint> complaints(GuestReview review) {
        List<Complaint> complaints = new ArrayList<>();
        gather(complaints, review.title());
        gather(complaints, review.body());
        for (StaffReply reply : review.replies()) {
            gather(complaints, reply.text());
        }
        return List.copyOf(complaints);
    }

    private static void gather(List<Complaint> complaints, String text) {
        if (text == null || text.isBlank()) {
            return;
        }
        for (String line : text.split("\\R", -1)) {
            Matcher matcher = COMPLAINT_LINE.matcher(line);
            if (matcher.matches()) {
                complaints.add(new Complaint(matcher.group(2).strip(), urgency(matcher.group(1))));
            }
        }
    }

    private static Urgency urgency(String heading) {
        return heading.toLowerCase(Locale.ROOT).startsWith("urgent") ? Urgency.URGENT : Urgency.NORMAL;
    }

    enum Urgency { URGENT, NORMAL }
    record StaffReply(String author, String text) {}
    record GuestReview(String title, String body, List<StaffReply> replies) {}
    record Complaint(String topic, Urgency urgency) {}
}
```

What must stay true:

- Complaints come out in reading order: title lines, then body lines, then each reply's lines in
  the order the replies are stored.
- Any of the three texts may be `null` or blank and then adds nothing.
- Review text only ever contains `\n` or `\r\n` line breaks.
- Only a line that matches `COMPLAINT_LINE` as a whole counts.
- The caller cannot modify the list `complaints` returns.
- `COMPLAINT_LINE`, `urgency`, and the nested types stay as they are.
