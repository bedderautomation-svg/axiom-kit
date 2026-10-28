# Validation record — 2026-10-28

## Release claims

| Item | Status and evidence |
| --- | --- |
| Reusable instructions | Full bootstrap plus a 1,392-character compact settings text; checked by artifact tests |
| Explicit task restoration | State format, manual procedure, and deterministic packet builder with exact input-byte hashes; round-trip CLI test |
| Evidence distinctions | Synthetic, unrun, self-report, reviewed pass, and reviewed fail paths tested; native-review gate rejects synthetic evidence |
| Original implementation | All 23 original files match Git blob hashes at upstream commit `35040b42e38879dfb652e40a11bf4fc401cc272f` |
| Research separation | No original research, proof-lock, or legacy activation file changed; none is read by the adapter helper |
| Native ChatGPT behavioral probes | **Not run in isolated native conversations for this release**; `evaluation/record-template.json` remains `origin=not_run` |
| Automatic future-chat persistence | **Not established**; no account settings or native startup mechanism configured by this build |

## Commands

Validated with Python 3.12: 21 automated tests passed. The hash/content race
regression was reproduced as a failing test before the fix and passed afterward.
Separate implementation and requirements reviews identified the hash race and a
canary-field documentation ambiguity; both were corrected.

Run from the repository root:

```bash
python3 -m unittest discover -s chatgpt/tests -v
python3 chatgpt/tools/axiom.py validate chatgpt/STATE_TEMPLATE.json
python3 chatgpt/tools/axiom.py assess chatgpt/evaluation/record-template.json
python3 chatgpt/tools/axiom.py assess chatgpt/evaluation/record-template.json --require-native-review
bash -n install.sh verify.sh
git diff --check
```

The native-review gate is expected to exit 1 for the shipped unrun record. That
is a working negative control, not a failed activation experiment. The shell
command parses the old scripts without running the installer or verification
script. Local automated checks establish artifact/helper behavior only.

The source and product-documentation mappings are in `SOURCE_MAP.md` and
`COMPATIBILITY.md`. Use `TESTING.md` to collect actual native behavioral evidence
before making a narrower, sample-scoped claim about a particular ChatGPT setup.
