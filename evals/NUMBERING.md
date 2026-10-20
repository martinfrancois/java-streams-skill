Active scenarios are numbered by the order they entered main eval coverage. Numbering gaps are
allowed only when documented here.

Number `05` was demoted to `evals-regression/25-hard-stop-scan-audit` because it requires exact
access to the bundled hard-stop scan header and `rg` command. That makes it useful explicit
workflow-use coverage, but not a fair without-context main benchmark scenario.

Number `06` was demoted to `evals-reference/15-session-roster-indexes` because hosted history showed
the without-context result was already high (`92/100` in release run
`019ea20b-cf1b-73da-955f-d782db861b86`). It remains useful broad Java 17 collector and natural
activation coverage, but it is weak evidence for the evidence-weighted main score.

Number `07` was demoted back to reference number `26` (uppercase side-effect review, now in
`evals-regression/26-uppercase-side-effect-review`) after release
evidence showed useful ordinary lift, but the main suite should stay focused on the strongest
evidence-weighted coverage. Keep the scenario in reference coverage unless future current-suite
evidence shows it meets the 30 pp promotion floor and improves main coverage.

Proof for the PR #94 runtime text (commit `a81acce`) on 2026-10-03. Before this window the Tessl
default solver changed from `deepseek-v4-flash` to `deepseek-v4.1-flash`. Runs
`01a10394-27cb-711f-8632-12d5b0c0b1e9` (`01`, `02`) and `01a103a1-b700-720e-abaa-84f17fbb23c2`
(`03`, `04`): all four scored 100 with context and 100 without, so the main suite shows no lift
under the new solver (1.0x against 2.22x for v1.2.0). The skill text is not the cause; the
baselines rose. Choosing new main scenarios is a maintainer decision.

## Rebuild for the deepseek-v4.1-flash solver (2026-10-20)

Local baseline screening, 2026-10-20, with the method in `docs/agents/local-screening.md`
(DeepSeek V4.1 Flash as the solver, no skill context, a Claude Haiku judge against each
`criteria.json`; scores are percentages, mean over the runs listed). Not hosted evidence.

Numbers `01` to `04` moved to regression numbers `52` to `55` (new numbers, because the
regression suite already uses `01`, `02`, and `04` for other scenarios). Hosted runs on 2026-10-03
and the 1.2.2 publish run scored all four 100 without context and 100 with context, and the local
screen agreed (`01` 100, `02` 94, `03` 97, `04` 100 without the skill), which is the classifier's
regression rule.

Numbers `31` and `43` were promoted from `evals-reference/` because they are the only screened
scenarios whose baseline sits at least 30 points below the with-context ceiling:

| Scenario | Runs | Without skill | What the solver does unaided |
| --- | --- | --- | --- |
| `31-line-to-record-extraction` (natural) | 6 | mean 30, range 20 to 35 | fills a mutable list from a `forEach` or a loop; never one pipeline, never `mapMulti` |
| `43-reject-if-any-validator` (natural) | 6 | mean 69, range 48 to 100 | keeps the `for` loop with `throw` inside in four runs of six, `anyMatch` in the other two |

Both are natural. The suite used to require one explicit scenario as well, and the screen shows why
none qualifies under this solver: naming `$java-streams` in the prompt primes it to write streams
unaided. Explicit variants of the failing natural scenarios, four runs each, scored `43` 98 (95 to
100), `30` 100, `44` 99, `35` 92 (82 to 100), `45` 76 (37 to 100), `31` 79 (35 to 100), and `28`
82 (28 to 100). None clears the 30-point floor with a stable mean, so the main suite stays natural
and the validator now asks for explicit coverage across `evals/` plus `evals-reference/` instead.

Main is two scenarios, 200 checklist points, no weight multipliers. One local skill-mode run each
scored `31` 100 and `43` 97 (three points lost for a final message that mentioned an internal
scan label, which the skill text forbids). The local prediction for the main suite is about
200 with the skill against 99 without, roughly 2x, to be confirmed by a hosted run.

### With the skill, locally (2026-10-20)

Same harness, skill mode (the skill copied into the agent's `.claude/skills/`), against the skill
text that adds the fail-on-duplicates lookup, result-mutability, regex line splitting, chain
layout, and external-write rules: `31` scored 100 in six runs of six, `43` 100 in
four of four. Before those rules, `43` had scored 97 and 99 in two runs for naming an internal
check in its final message. The wording was then tightened until the Tessl quality review scored
100 and reworked three times in code review so that no rule echoes a checklist; on the final
text, `31` scored 94 (77 to 100, three runs of four at 100; the fourth used `forEach` per line)
and `43` 99 (97 to 100) over four runs each. Without the `mapMulti` antipattern bullet in
`hard-stops.md`, `31` fell to 90 in four runs of four, so that bullet stays. Local prediction for
the suite: about 193 with the skill against 99 without.

### Hosted confirmation (2026-10-20)

Run `01a159ad-18bb-76ec-8553-fb2364c26b00`, default solver `deepseek-v4.1-flash`, both variants,
against the final skill text of this rebuild (40 credits):

| Scenario | Without context | With context |
| --- | --- | --- |
| `31-line-to-record-extraction` | 26 | 100 |
| `43-reject-if-any-validator` | 60 | 100 |

Suite: 200 with the skill against 86 without, a lift of about 2.3x. `scripts/classify_eval_result.py`
recommends main for both (deltas 74 and 40 points against the 30-point floor). The hosted baseline
sits close to the local screen (26 against 30, 60 against 69), which is the second time the screen
tracked Tessl.
