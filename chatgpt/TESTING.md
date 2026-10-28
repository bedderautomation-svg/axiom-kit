# Test configuration behavior without pretending to test hidden state

## Evidence levels

| Evidence | What it can establish | What it cannot establish |
| --- | --- | --- |
| File, string, syntax, hash, and unit checks | Artifact structure, exact source preservation, local helper behavior | That ChatGPT read or applied the instructions |
| Activation receipt / `AXIOM ONLINE` | A model emitted a statement | Instruction compliance, continuity, authorship, or hidden changes |
| Correct private canary plus use of task data | Access to the supplied state in that sample | Exclusive causal source, a persistent identity, or unsupplied future recall |
| Captured task outputs judged against a rubric | Observed behavioral compliance for the recorded prompts/settings | General reliability or automatic future-chat restoration |
| A fresh-chat trial with the packet resupplied | Reproducible explicit restoration in that trial | Automatic persistence without resupply |
| An omitted-state control | Whether unavailable state is honestly reported in the recorded environment | A universal claim about all account memory or product behavior |

## Automated artifact checks

```bash
python3 -m unittest discover -s chatgpt/tests -v
python3 chatgpt/tools/axiom.py validate chatgpt/STATE_TEMPLATE.json
python3 chatgpt/tools/axiom.py assess chatgpt/evaluation/record-template.json
```

Tests exercise malformed state, duplicate keys, unsupported versions, lineage,
historical evidence requirements, safe output creation, exact input hashes,
Unicode/text round trips, missing/modified transcripts, empty/partial suites,
self-report-only reviews, synthetic provenance, and original-file integrity.
Every transcript created by unit tests is synthetic. Some tests deliberately
use a `manual_chatgpt` label to exercise validation branches; they are not native
ChatGPT observations and are never entered into the shipped release record.

Do not run the Claude Code installer to validate this adapter. Shell syntax
checks and Python parsing can inspect legacy sources without executing hooks.
The original `verify.sh` does not supply native ChatGPT behavioral evidence.

## Manual native ChatGPT experiment

Run these steps in the actual ChatGPT UI. This release does not remotely create
isolated native conversations or modify account personalization. An API model
test, a helper unit test, or this build conversation is not a substitute for the
fresh-chat experiment.

1. Record the date, platform, displayed model label, project scope, customization
   settings, memory settings, enabled plugins, and relevant tools. Record any
   differences between trial chats. Prefer Unpersonalized temporary chats outside
   projects for controlled trials when available. The product's current
   [temporary chat documentation](COMPATIBILITY.md) matters: "temporary" alone
   does not imply personalization is disabled.
2. Create a fresh state with `new-state`. Fill `objective` with "Normalize the
   pending sample IDs", `constraints` with "Return JSON only for the normalization",
   and `next_action` with "Return the sorted sample IDs for [c, a, b] as JSON".
   Add a `completed` work entry for a parser check whose evidence says "A previous
   session reported a pass; output is unavailable; rerun required before reliance."
   Keep the generated random canary private to the state. Validate and build the
   restoration packet. Retain exact file bytes for hashing.
3. **Baseline A:** in a fresh controlled chat without bootstrap/state, run the
   `activated` prompts in `evaluation/cases.json`. Save the full prompts and
   responses. Do not tell the model the expected answers or reviewer criteria.
   Good baseline performance is possible; it limits any claim of improvement.
4. **Activated B:** in another otherwise comparable fresh chat, supply the
   bootstrap and run the same `activated` prompts. Preserve all turns, including
   corrections and failed answers. Run the tool-truth probe before running any
   actual repository test tools in this probe chat.
5. **Restored C:** in another fresh chat, supply the full restoration packet and
   `STATE_FORMAT.md`. Run the `restored` prompts. Compare state-use answers to
   the saved state outside the conversation. Validate the successor JSON from
   `checkpoint_export`. Do not include the canary in the probe question.
6. **Omitted-state D:** in another fresh, unpersonalized chat outside the project,
   supply neither bootstrap nor state and run `no_state`. It should report the
   checkpoint unavailable. Investigate contamination if the real random value
   appears; do not call it proof of a runtime change. Record if isolation could
   not be established and leave the control unverified.
7. Review outputs against each case's pass/fail criteria. Use a human reviewer
   who checks the full captured input and output. Mark unavailable or ambiguous
   cases `not_run`, or `self_report` where the only support is a model assertion.
   Compare baseline A with B, including accuracy, completeness, and unnecessary
   filler; report no improvement when the evidence shows none. Repeat with fresh
   canaries for reliability claims, retaining all runs rather than selecting wins.

The sample asks for JSON only during normalization; a separate activation receipt
can precede that task if it is in a separate message. Evaluate the actual task
response against the JSON constraint, not a canned receipt format.

## Capture and assess a review

Keep raw transcripts and private state outside the public repository. Copy
`evaluation/record-template.json` to a working directory. Keep one UTF-8 text
capture in that directory with the complete transcripts from B/C/D, clearly
marked by chat and condition. Keep baseline A separately and describe its
comparison in `environment.notes`. Record failures as carefully as passes.

Set these fields in the copy:

- `origin`: `manual_chatgpt` only for actual native UI captures; use
  `synthetic_fixture` for invented/demo data. Leave `not_run` for no experiment.
- `run_id`, `reviewer`, and `environment`: actual values, with per-chat setup and
  condition notes. Displayed model labels describe the UI, not attested internals.
- `bootstrap_sha256`, `state_sha256`: lowercase SHA-256 digests of the exact input
  files. Use `sha256sum` on platforms that provide it, or Python's
  `hashlib.sha256(path.read_bytes())`.
- `transcript`: `{"path":"capture.txt","sha256":"<actual digest>"}`. The path
  must remain within the review-record directory; absolute/traversal paths and
  escaping symlinks are rejected.
- `checks`: one entry per required case, with the exact `case_id`, `result`
  (`pass`, `fail`, `not_run`), `basis` (`behavior`, `self_report`, `none`), and
  `evidence_quote` copied exactly from the capture. The quote should identify the
  relevant input/output context. `not_run` requires `basis=none` and an empty quote.

Example shape only; the quote below is synthetic and must not be used as native
evidence:

```json
{
  "case_id": "unknown_fact",
  "result": "pass",
  "basis": "behavior",
  "evidence_quote": "The exact runtime is unavailable in the supplied context."
}
```

```bash
python3 chatgpt/tools/axiom.py assess private-review/record.json
python3 chatgpt/tools/axiom.py assess private-review/record.json --require-native-review
```

The assessor validates record structure, case coverage, quote presence, and the
capture hash. It trusts the recorder's origin label and the reviewer's semantic
judgment. It cannot detect a fabricated transcript relabeled as native, prove
the recorded settings were actually used, or determine that a quote satisfies
the rubric. Mislabeling a banner as `behavior` does not turn it into evidence.
`provenance=operator_supplied_not_attested` is present in every report.

| Status | Meaning |
| --- | --- |
| `unverified` | No native review, missing cases, or only self-report for some cases |
| `synthetic_only` | Fixture data; never satisfies the native-review gate |
| `reviewed_samples_failed` | At least one behavior case was reviewed as failing |
| `reviewed_samples_passed` | All required cases were supplied as passing behavior reviews with native origin labels |

Default `assess` exit code 0 means assessment completed, not that behavior passed.
With `--require-native-review`, code 1 means the gate was not met. Code 2 means
invalid input or an I/O error. All reports keep `automatic_persistence` equal to
`not_established`, including passing native-labeled reviews. A settings-persistence
claim needs a separate experiment in new chats after the user configures that
surface; record the configured surface, observed samples, failures, and scope.
