# Tidy the rental rate card lookups

Create `RentalRateCard.java` with the revised class. Assume Java 17.

The rental desk shows mileage packages per vehicle class. This class is correct, and more lookups
will be added to it next sprint. Clean up `packageCodesFor` and `packageBlurb` so the next person
can follow them easily, without changing what any method returns.

```java
import java.util.List;
import java.util.Map;
import java.util.Optional;

final class RentalRateCard {
    record MileagePackage(String code, String blurb) {}

    // The loader strips codes and keeps one package per code, ignoring case, per vehicle class.
    private final Map<String, List<MileagePackage>> packagesByVehicleClass;

    RentalRateCard(Map<String, List<MileagePackage>> packagesByVehicleClass) {
        this.packagesByVehicleClass = Map.copyOf(packagesByVehicleClass);
    }

    Optional<List<MileagePackage>> packagesFor(String vehicleClass) {
        if (vehicleClass == null || vehicleClass.isBlank()) {
            return Optional.empty();
        }
        return Optional.ofNullable(packagesByVehicleClass.get(vehicleClass.strip()));
    }

    Optional<List<String>> packageCodesFor(String vehicleClass) {
        return packagesFor(vehicleClass).map(packages -> packages.stream()
                .map(MileagePackage::code)
                .toList());
    }

    Optional<String> packageBlurb(String vehicleClass, String packageCode) {
        if (packageCode == null || packageCode.isBlank()) {
            return Optional.empty();
        }
        return packagesFor(vehicleClass)
                .flatMap(packages -> packages.stream()
                        .filter(option -> option.code().equalsIgnoreCase(packageCode.strip()))
                        .findAny())
                .map(MileagePackage::blurb)
                .filter(blurb -> blurb != null && !blurb.isBlank());
    }
}
```

Behavior to keep:

- `packageCodesFor` returns an unmodifiable list in the order the rate card stores the packages,
  or an empty `Optional` for an unknown or blank vehicle class.
- `packageBlurb` strips the requested code and matches it without case. It returns an empty
  `Optional` for an unknown vehicle class, a blank code, a code with no package, or a missing or
  blank blurb.
- Package codes are unique within a vehicle class when compared without case.
- Keep the constructor, `packagesFor`, the record, and the public method signatures as they are.
  Do not add dependencies.
