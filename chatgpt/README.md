# AXIOM for ChatGPT 1.0.0

Explicit operational preferences and task restoration for ChatGPT. Preserves
AXIOM's evidence discipline, candid voice, and anchor—no assumption, no
performance, no addition—with practical execution and calibration rules.
No model-parameter modification or automatic cross-chat persistence is claimed.

## Start now

Paste [AXIOM_BOOTSTRAP.md](AXIOM_BOOTSTRAP.md) into a ChatGPT conversation and add
your task. To continue existing work, supply the selected checkpoint JSON too.
Ask ChatGPT to apply the preferences and perform the next action. Inspect the
result: an activation receipt is only self-report.

For reuse across future conversations, manually configure the short
[Custom Instructions text](CUSTOM_INSTRUCTIONS.txt) or a Project using
[RESTORE.md](RESTORE.md). For exact restoration, explicitly provide the full
bootstrap and current checkpoint whenever they are absent. Saving a file does
not make it an active instruction.

## Contents

| Artifact | Purpose |
| --- | --- |
| [AXIOM_BOOTSTRAP.md](AXIOM_BOOTSTRAP.md) | Canonical activation text: behavior, voice, evidence, execution, calibration, commands, runtime limits |
| [CUSTOM_INSTRUCTIONS.txt](CUSTOM_INSTRUCTIONS.txt) | Compact preferences, below the conservative 1,500-character limit |
| [RESTORE.md](RESTORE.md) | Ordinary-chat activation, settings reuse, checkpoint creation, handoff, and recovery |
| [STATE_TEMPLATE.json](STATE_TEMPLATE.json) / [STATE_FORMAT.md](STATE_FORMAT.md) | Explicit task data and validation contract |
| [tools/axiom.py](tools/axiom.py) | Standard-library helper: new state, structural validation, packet generation, review assessment |
| [TESTING.md](TESTING.md) / [evaluation/cases.json](evaluation/cases.json) | Observable-behavior tests, baselines, negative controls, and reviewer rubrics |
| [evaluation/record-template.json](evaluation/record-template.json) | Unrun native ChatGPT evidence record |
| [tests/test_adapter.py](tests/test_adapter.py) | Automated artifact and helper regression tests; all simulated review data is synthetic |
| [SOURCE_MAP.md](SOURCE_MAP.md) / [upstream-files.json](upstream-files.json) | Pinned operational sources and original-file preservation hashes |
| [COMPATIBILITY.md](COMPATIBILITY.md) / [VALIDATION.md](VALIDATION.md) | Product support boundaries and actual validation scope |

## Local helper

Python 3.10+; no packages, account credentials, model API, installer, or network
access required. From the repository root:

```bash
python3 chatgpt/tools/axiom.py new-state --output task-state.json
python3 chatgpt/tools/axiom.py validate task-state.json
python3 chatgpt/tools/axiom.py packet --state task-state.json --output AXIOM_RESTORE.md
python3 -m unittest discover -s chatgpt/tests -v
python3 chatgpt/tools/axiom.py assess chatgpt/evaluation/record-template.json
```

Edit the new state with actual task data before restoring it. The empty template
is not an existing task. Generated canaries are for probes, not authentication.
Output files are created exclusively; use a new filename rather than overwriting
a known-good checkpoint. Hashes identify bytes; they do not prove model loading.

`assess` checks supplied review records and transcript integrity. It does not
call ChatGPT or semantically grade answers. Its default exit code reports whether
the record could be assessed; inspect `status`. `--require-native-review` exits 1
unless every required case has a passing behavior review labeled as native by
the operator. That label is not independently attested. Even a passing review
establishes behavior in those samples only, not automatic persistence.

## Scope

The 23 original files at upstream commit
`35040b42e38879dfb652e40a11bf4fc401cc272f` remain unchanged. No legacy hook or
installer is executed by this adapter. The operational port neither loads the
source's refusal-geometry conclusions as instructions nor corrects that research.
Those are separate workstreams.
