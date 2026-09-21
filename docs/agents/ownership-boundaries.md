# Ownership Boundaries

## Scope

Use this when changing runtime guidance, README wording, evals, or companion-package documentation
for Java Streams. This page holds the only full list of who owns what; other pages link here.

## Rules

- `java-streams` owns stream and collector semantics: terminal operation choice, collector choice,
  duplicate-key and null behavior, encounter order, primitive streams, `findFirst` versus
  `findAny`, `parallelStream`, `Gatherers.mapConcurrent`, stream Java-version compatibility, and
  stream-specific behavior preservation. It also keeps its own short "lambdas as glue" rule and its
  preference for method references, because the published stream evals measure them.
- `martinfrancois/java-functional-style` owns general Java lambda and functional-interface style:
  identity functions, no-op functional stages, helper extraction from block callbacks, comparator
  composition, method-reference pitfalls (receiver binding, overloads, boxing), supplier laziness,
  checked-exception boundaries inside callbacks, and callback side-effect boundaries.
- `martinfrancois/java-optionals` owns Optional semantics.
- Each package works on its own. Don't make stream guidance depend on the companion being installed,
  and don't remove stream guidance because the companion also covers it.
- Don't grow generic lambda guidance here. When a functional-style gap shows up in stream work, fix
  it in the companion and add stream-side text only if hosted evidence proves the stream evals need
  it.

## Composition Check

Adding the companion must not make this skill worse. The check runs this repository's evals,
unchanged, with both skills injected as context and requires 100% with-context for every scenario
in the run:

```bash
# from a checkout of java-functional-style-skill, next to this repository
scripts/run_composed_eval.sh ../java-streams-skill main
```

The main suite is required whenever either package changes runtime text; run `reference` and
`regression` too when the change touches review wording or when budget allows. The companion
repository owns the runner and runs the check before its releases; this repository runs it when
its own runtime changes. Local validation alone doesn't satisfy this check.

## References

- [Skill Behavior](skill-behavior.md)
- [README Guidance](readme.md)
- [Eval Guidance](evals.md)
- [Workflow](workflow.md)
