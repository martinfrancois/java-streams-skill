# Revise the calibration offset validation

Create `CalibrationProfileLoader.java` with the revised class. Assume Java 17.

This loader reads per-sensor offsets for a telemetry device. The validation below passed review and
works, but a teammate asked whether `rejectUnusableOffsets` could read better. Revise the class
where it makes the code clearer, and keep its behavior identical.

```java
import java.util.List;
import java.util.Map;

final class CalibrationProfileLoader {
    record SensorOffset(String sensorId, Double offset, Map<String, String> tags) {}
    record CalibrationProfile(String deviceModel, List<SensorOffset> offsets) {}

    static final class CalibrationException extends RuntimeException {
        private final String code;

        CalibrationException(String code, String message) {
            super(message);
            this.code = code;
        }

        String code() {
            return code;
        }
    }

    CalibrationProfile load(String deviceModel, List<SensorOffset> offsets) {
        rejectUnusableOffsets(offsets);
        return new CalibrationProfile(deviceModel, offsets);
    }

    private static void rejectUnusableOffsets(List<SensorOffset> offsets) {
        for (SensorOffset candidate : offsets) {
            if (candidate.sensorId() == null || candidate.sensorId().isBlank()
                    || candidate.offset() == null || !Double.isFinite(candidate.offset())) {
                throw new CalibrationException(
                        "calibration_invalid", "Every calibration offset needs a sensor id and a finite value");
            }
        }
    }
}
```

Constraints:

- Throw the same `CalibrationException` code and message for every unusable offset. Callers match
  on the code.
- Validation stops at the first unusable offset.
- Only `sensorId` and `offset` are checked. `tags` may contain `null` values and must stay
  unvalidated.
- `load` still validates before it builds the profile.
- Keep the public types, the method signatures, and the exception class as they are. Do not add
  dependencies.
