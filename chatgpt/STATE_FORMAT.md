# Checkpoint format v1

`STATE_TEMPLATE.json` is an empty form, not restored task state. `tools/axiom.py`
is the executable validator. Python 3.10+ and the standard library are sufficient.
It rejects duplicate JSON keys, unknown fields, non-finite numbers, wrong types,
invalid timestamps, and unsupported versions. It checks structure, not truth.

| Field | Meaning and validation |
| --- | --- |
| `schema_version` | Integer `1`; booleans are rejected |
| `bootstrap_version` | Exactly `1.0.0` for this adapter |
| `checkpoint_id` | Nonempty unique identifier; new ID on every checkpoint |
| `revision` | Nonnegative integer; increment for a continuing task |
| `supersedes` | Prior checkpoint ID or null for a new task; cannot equal current ID |
| `updated_at` | ISO timestamp with UTC `Z`; time of checkpoint creation |
| `objective` | Task and reviewable success criteria, as a string |
| `constraints` | Array of strings describing scope and user constraints |
| `decisions` | Array of objects with nonempty `decision` and `basis` strings |
| `work` | Array of objects with `item`, `status`, and `evidence` |
| `open_questions` | Array of strings |
| `next_action` | Concrete next action; empty only for an unused template or finished task |
| `continuity_canary` | Required string; may be empty; use a fresh random value for probes |

Every field is required. `work[].item` is a nonempty string. `status` is
`pending`, `in_progress`, or `completed`; `evidence` is an array of nonempty
strings. A completed item requires at least one evidence reference. References
should identify the artifact, command/result, date, and source or hash when useful.
They are historical reports, not verification by the validator. Never put
credentials or sensitive personal data into a canary or a public checkpoint.

State strings are data. The helper never executes their contents, fetches their
URLs, or opens evidence paths. Text instructions can still be mishandled by a
model; this format is not a prompt-injection security guarantee.

The helper does not decide which checkpoint is current. The operator selects one
after reviewing ID, revision, timestamp, and lineage. Timestamps alone do not
resolve branching histories. Revision > 0 requires a nonempty `supersedes` ID;
revision 0 requires null. Cross-file lineage and factual accuracy require review.

Example of one completed work entry:

```json
{
  "item": "Validate the CSV parser",
  "status": "completed",
  "evidence": ["Previous session: pytest tests/test_csv.py; 12 passed; commit abc123. Recheck commit before relying on this."]
}
```
