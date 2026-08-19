# Ownership Boundaries

`java-streams` owns stream and collector semantics:

- terminal operation choice
- collector choice
- duplicate key and null behavior
- encounter order
- primitive streams
- stream Java-version compatibility
- `findFirst` versus `findAny`
- `parallelStream`
- `Gatherers.mapConcurrent`
- stream-specific behavior preservation

`java-functional-style` owns general Java lambda and functional-interface style:

- method references
- identity functions
- no-op functional stages
- callback readability and helper extraction
- supplier laziness
- callback side-effect boundaries

`java-optionals` owns Optional semantics.

The expected high-quality setup for stream cleanup involving non-trivial callbacks is both
`java-streams` and `java-functional-style`.

Do not copy all generic lambda guidance back into `java-streams` to fix composition regressions.
Add only the smallest stream-side bridge instruction if hosted evidence proves it is required.

## Composition Gate

Before opening a PR for this split, existing stream evals must prove:

```text
current java-streams behavior <= slimmed java-streams + java-functional-style behavior
```

The comparison must use existing evals unchanged and criterion-level results must be equal or
better. Local validation alone is not enough.
