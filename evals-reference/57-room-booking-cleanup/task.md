# Tidy the room booking confirmation

Create `RoomBooker.java` with the revised class. Assume Java 17.

This class confirms meeting room requests for an office floor. It works and passed review, but a
teammate asked whether it could read better. Revise it where that makes the code clearer, say in a
comment why each change is clearer, and keep its behavior: a request for a room name that matches no
room is skipped, a name that matches more than one room is an error, and callers cannot modify the
returned list.

```java
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

final class RoomBooker {
    record Room(String name, int capacity) {}
    record Request(String roomName, int attendees, String organizer) {}
    record Reservation(Room room, String organizer) {}

    List<Reservation> confirmed(List<Request> requests, List<Room> rooms) {
        List<Reservation> result = new ArrayList<>();
        for (Request request : requests) {
            Room room = roomNamed(rooms, request.roomName());
            if (room != null && room.capacity() >= request.attendees()) {
                result.add(new Reservation(room, request.organizer()));
            }
        }
        return Collections.unmodifiableList(result);
    }

    private static Room roomNamed(List<Room> rooms, String name) {
        Room found = null;
        for (Room room : rooms) {
            if (room.name().equalsIgnoreCase(name)) {
                if (found != null) {
                    throw new IllegalStateException("Ambiguous room name: " + name);
                }
                found = room;
            }
        }
        return found;
    }
}
```
