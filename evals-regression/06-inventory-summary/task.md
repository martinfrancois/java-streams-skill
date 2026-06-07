# Clean up inventory summary streams

Create `InventorySummary.java` with the revised class. Assume Java 8.

The current implementation works, but it was written quickly. Keep the same behavior and make the
stream code more direct.

```java
import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.StringJoiner;
import java.util.stream.Collectors;

final class InventorySummary {
    Summary summarize(List<Product> products, List<Message> messages) {
        List<Product> outOfStockProducts = products.stream()
                .filter(product -> product.stock() == 0)
                .collect(Collectors.toList());
        boolean anyOutOfStock = !outOfStockProducts.isEmpty();

        List<Message> unreadMessages = messages.stream()
                .filter(message -> !message.read())
                .collect(Collectors.toList());
        int unreadCount = unreadMessages.size();

        List<Product> sortedByUpdated = products.stream()
                .sorted(Comparator.comparing(Product::updatedAt).reversed())
                .collect(Collectors.toList());
        Product newest = sortedByUpdated.isEmpty() ? null : sortedByUpdated.get(0);

        List<String> categories = new ArrayList<>();
        for (Product product : products) {
            categories.add(product.category());
        }
        StringJoiner joiner = new StringJoiner(", ");
        for (String category : categories) {
            joiner.add(category);
        }

        return new Summary(anyOutOfStock, unreadCount, newest, joiner.toString());
    }

    static final class Product {
        private final String category;
        private final int stock;
        private final Instant updatedAt;

        Product(String category, int stock, Instant updatedAt) {
            this.category = category;
            this.stock = stock;
            this.updatedAt = updatedAt;
        }

        String category() { return category; }
        int stock() { return stock; }
        Instant updatedAt() { return updatedAt; }
    }

    static final class Message {
        private final boolean read;

        Message(boolean read) {
            this.read = read;
        }

        boolean read() { return read; }
    }

    static final class Summary {
        final boolean anyOutOfStock;
        final int unreadCount;
        final Product newest;
        final String categories;

        Summary(boolean anyOutOfStock, int unreadCount, Product newest, String categories) {
            this.anyOutOfStock = anyOutOfStock;
            this.unreadCount = unreadCount;
            this.newest = newest;
            this.categories = categories;
        }
    }
}
```
