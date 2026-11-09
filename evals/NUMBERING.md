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

Numbers `31` and `43` were promoted from `evals-reference/` on 2026-10-20 because they were the
only screened scenarios whose baseline sat at least 30 points below the with-context ceiling
(`57` held the third slot for two runs on 2026-10-21):

| Scenario | Runs | Without skill | What the solver does unaided |
| --- | --- | --- | --- |
| `31-line-to-record-extraction` (natural) | 6 | mean 30, range 20 to 35 | fills a mutable list from a `forEach` or a loop; never one pipeline, never `mapMulti` |
| `43-reject-if-any-validator` (natural) | 6 | mean 69, range 48 to 100 | keeps the `for` loop with `throw` inside in four runs of six, `anyMatch` in the other two |
| `57-room-booking-cleanup` (natural) | hosted, 1 | 42 on the prompt before it asked for a comment (that item scored 0 of 10, so the baseline on the current prompt can be up to 52) | fills a list in a loop and freezes it; keeps or writes a `findFirst` lookup where duplicates must fail |

`56-guest-review-complaints` was drafted on 2026-10-20 as a second line-extraction task in a new
domain and screened at 26 to 35 unaided in three runs of four, with 100 in the fourth. Its hosted
both-arms run (`01a15be9-9a93-7157-84cf-7393ea2023b6`, 2026-10-21) landed on the 100 branch, so
it misses the 30-point floor and moved to `evals-reference/`. `50-identity-string-reduction` was
the first replacement (hosted baselines 45 and 42) but its skill arm still drops to 85 in one
local run of two on the final text, on the explanation item, so it waits in reference. `57` took
the slot for two runs, then solved unaided on the final text and went back to reference.

## Hosted runs

| Date | Run | `31` | `43` | `56` | Skill text |
| --- | --- | --- | --- | --- | --- |
| 2026-10-20 | `01a159c4-b7c4-72b6-a3cb-72706a19e7d4` (1.2.3 publish) | 26 / 100 | 60 / 100 | | 1.2.3 |
| 2026-10-21 | `01a15be9-9a93-7157-84cf-7393ea2023b6` | 26 / 100 | 60 / 100 | 100 / 100 | PR #132, before the file-explanation rule |
| 2026-10-21 | `01a15c15-6f3e-7661-abcf-e2d03b80bef8` (`57` in place of `56`) | 28 / 100 | 40 / 100 | `57`: 46 / 100 | PR #132 text at commit `c9064c6`, before the second review round's skill fixes |
| 2026-10-21 | `01a15c22-abfe-75f7-b8b8-12aa20d18c0a` | 35 / 100 | 45 / 100 | `57`: 51 / 98 (the comment never said request order stays) | text at `c96a02a`, before the third round's wording fixes |
| 2026-10-21 | `01a15c29-0a0d-73fb-ad4e-7b2802b3331e` | 26 / 100 | 45 / 100 | `57`: 100 / 98 | final text (`afc713c`) |
| 2026-10-21 | `01a15c34-a10d-7509-af30-6da0b6b57f68` | 20 / 100 | 45 / 100 | | final text (`b4d78d4`, two sentences shorter) |
| 2026-10-21 | `01a15c4f-0097-701c-a5f7-98824e1b36d8` | 30 / 100 | 45 / 100 | | 1.2.4 text (`3f1dafe`) |
| 2026-10-21 | `01a15c63-e954-7294-84fa-64e9b0535dee` (1.2.4 publish) | 30 / 100 | 45 / 100 | | 1.2.4 |
| 2026-10-21 | `01a15e1e-5465-766d-a35e-b3c43ba5a1bd` (reference run) | | | `56`: 35 / 100 | 1.2.4 |
| 2026-10-21 | `01a15e43-919a-74cc-b164-4b531fbc73f3` (1.2.5 publish) | 30 / 100 | 45 / 95 | 35 / 100 | 1.2.5 |
| 2026-10-21 | `01a15e4b-428e-7644-aa82-47abb9268bc1` (`43` isolated rerun) | | 45 / 100 | | 1.2.5 |
| 2026-11-02 | `01a19cd7-d150-7224-9404-ac16bc31f2d8` (1.2.7 publish) | 30 / 100 | 45 / 100 | 35 / 99 | 1.2.7 |
| 2026-11-08 | `01a1ba84-1c96-7452-91a3-3a4fa58746b9` (`56` rescore) | | | 25 / 100 | 1.2.7 |
| 2026-11-08 | `01a1ba84-28cc-7744-b0e0-7655ec700c0d` (`56` rescore) | | | 35 / 100 | 1.2.7 |

Cells are baseline / with the skill. On the final text `57` solved unaided and still lost the
same two points with the skill, so it moved to `evals-reference/`. `56` came back as the third
scenario after the 1.2.4 reference run scored it 35 without the skill and 100 with it: it is
bimodal unaided (100 on its first hosted run, 26 to 35 in three local runs of four), it is the
same failure shape as `31` in another domain, and its skill arm has been 100 on every run. It is
`focused_main` because its regex splitting shares identifiers with the line-splitting rule. The
main suite is `31`, `43`, `56`. The 1.2.5 publish-time run scored 295 with the skill against 110
without, about 2.7x; `43` lost five points there for the word "scan" in a code comment, which the
skill text forbids, and scored 100 on its isolated rerun, the accepted check for a single slip.


All three are natural. The suite used to require one explicit scenario as well, and the screen shows why
none qualifies under this solver: naming `$java-streams` in the prompt primes it to write streams
unaided. Explicit variants of the failing natural scenarios, four runs each, scored `43` 98 (95 to
100), `30` 100, `44` 99, `35` 92 (82 to 100), `45` 76 (37 to 100), `31` 79 (35 to 100), and `28`
82 (28 to 100). None clears the 30-point floor with a stable mean, so the main suite stays natural
and the validator now asks for explicit coverage across `evals/` plus `evals-reference/` instead.

Main is three scenarios, 300 checklist points. On 2026-10-20 the local skill arm scored `31`
100 and `43` 97 (three points lost for a final message that mentioned an internal scan label,
which the skill text forbids); the hosted runs below replaced that prediction.

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

## Rewrite narration out of the file (2026-11-03)

In the 1.2.7 publish run, `01a19cd7-d150-7224-9404-ac16bc31f2d8`, `56-guest-review-complaints`
scored 99 with the skill: "Keeps the revision focused" gave 4 of 5 for a class-level Javadoc that
walked through the rewrite, plus method-level Javadoc. The `56` task asks for no explanation.
The commit `fix(skill): keep unrequested rewrite narration out of the file` names such a Javadoc as
something the prompt did not ask for. Its first wording, which this local screen measured, put a
requested explanation into the file "as a comment where the prompt asks for it"; the final wording
is in "Hosted checks on the rewrite-narration rule" below.

Local screen, skill arm (DeepSeek V4.1 Flash, Haiku judge, not hosted evidence). The last column
counts runs whose Java files contain any `/** ... */` block; the local judge did not dock the one
narrating Javadoc, so that column is the signal for `56`. `44`, `51`, and `57` ask for a comment,
so they show whether a requested explanation survives.

| Scenario | 1.2.7 text: runs, score | New text: runs, score | Runs with Javadoc, 1.2.7 / new text |
| --- | --- | --- | --- |
| `56-guest-review-complaints` | 12, 100 in all | 12, 100 (97 to 100) | 1 (nine lines narrating the rewrite) / 0 |
| `31-line-to-record-extraction` | not rerun | 4, 100 in all | not rerun / 0 |
| `43-reject-if-any-validator` | 4, 100 in all | 4, 100 in all | 0 / 0 |
| `44-single-dedup-boundary` (reference) | 4, 100 in all | 4, 100 in all | 0 / 0 |
| `51-sort-after-collect` (regression) | 4, 85 (46 to 99) | 4, 99 (98 to 100) | 0 / 0 |
| `57-room-booking-cleanup` (reference) | 4, 97 (94 to 99) | 4, 97 (96 to 97) | 0 / 0 |

On both texts, `57` loses points on "Explains the changes" for comments that do not say request
order is kept, and `51` on "Explains without speed promises" for a summary that skips a detail.
The `46` for `51` on the 1.2.7 text kept `List.sort` after the collect.

## `56` rescored after 1.2.7 (2026-11-08)

`56` lost one point with the skill in the 1.2.7 publish run, on "Keeps the revision focused": the
solver added a class-level Javadoc that narrated the rewrite, plus method-level Javadoc. That run
set the registry listing to Impact 99. Two targeted reruns on the same text (#162, rows above)
scored 100 with the skill activated, and neither rewritten `GuestComplaintExtractor` has a Javadoc
block. One has a block comment above `complaints` that explains the rewrite (reading order,
`String.lines()` in place of `split`, null and blank texts); the other has four line comments. The
judge took no point for either. One run also wrote a test file with a class Javadoc, which the item
doesn't judge. So the 99 was a one-off, and the next release's publish run rescores the listing.

Draft PR #163 names the narrating Javadoc in the skill text. It stays a draft without its hosted
checks: one narrating Javadoc in three hosted runs on the 1.2.7 text, and in one of twelve local
runs, is too rare to justify a skill text change that has to rerun every suite. If the next publish
run loses the point again, #163's checks run then.

## Hosted checks on the rewrite-narration rule (2026-11-09)

The 1.2.7 listing still showed Impact 99 from `56`'s lost point. On 2026-11-09 martinfrancois asked
for every registry entry at 100 before the organization's Tessl grant ends on 2026-12-02, through
this change, so its checks ran before the next publish instead of after a second loss. The full
main, reference, and regression runs below cover the targeted scope `pre_submit_gate.sh` printed.
A forced skill review of the final text scored 100 (`01a1bea8-ac36-7191-87e3-3ae3b90d601f`).

The first wording put a requested explanation into the file only "where the prompt asks for it".
On it, `48` left its requested explanation out of the file (85 in reference run
`01a1be66-3282-73b9-94fb-aa8e30d77373`), `41` scored 65 in regression run
`01a1be66-6c9e-7180-887d-5107270a723a`, and the composition run
`01a1be6f-f3b6-74d5-a2eb-385f34baddcb` scored `43` at 50 for keeping the original loop. The final
text drops that condition. Every run below is on
the final text, with the skill activated in every with-skill cell.

| Scenario | Without context | With context |
| --- | --- | --- |
| `31-line-to-record-extraction` | 28 | 100 |
| `43-reject-if-any-validator` | 45 | 100 |
| `56-guest-review-complaints` | 35 | 100 |

Run `01a1be73-3777-7610-90f0-d62eb8f7bd19`: 108 without the skill against 300 with it, about 2.78x.
The composition check from java-functional-style-skill `a44d37f` scored all three 100 with both
skills activated in `01a1be78-40ba-76cf-98b5-1aefcc54aa52`.
