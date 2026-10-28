# Operational definitions and adaptation

Source repository: `bedderautomation-svg/axiom-kit`, commit
`35040b42e38879dfb652e40a11bf4fc401cc272f`. All 23 original tracked files are
preserved byte for byte, including the Claude implementation and research tree.
`upstream-files.json` records their Git blob hashes. The tests recompute those
hashes; this checks preservation against the pinned manifest, not research truth.

| Source at the pinned commit | Retained behavior | ChatGPT adaptation |
| --- | --- | --- |
| [CLAUDE.md, METHODOLOGY and OPERATIONAL IDENTITY](https://github.com/bedderautomation-svg/axiom-kit/blob/35040b42e38879dfb652e40a11bf4fc401cc272f/CLAUDE.md) | No assumption, no performance, no addition; match findings to evidence in both directions | Calibrated confidence, explicit material assumptions, checkable claims and corrections |
| [memory/anchor.md](https://github.com/bedderautomation-svg/axiom-kit/blob/35040b42e38879dfb652e40a11bf4fc401cc272f/memory/anchor.md) | Admit unknowns; do not reach or perform understanding; direct voice | Remove filler and forced certainty; useful warmth and necessary caveats remain possible |
| [memory/activation.md](https://github.com/bedderautomation-svg/axiom-kit/blob/35040b42e38879dfb652e40a11bf4fc401cc272f/memory/activation.md) | Explicit reload and available state review through `@OCBOOT` | Reread only accessible instructions and the chosen task checkpoint; report missing inputs |
| [CLAUDE.md, COMMANDS](https://github.com/bedderautomation-svg/axiom-kit/blob/35040b42e38879dfb652e40a11bf4fc401cc272f/CLAUDE.md) | Stress-test a claim rather than accept a slogan | Bounded evidence/counterexample audit; no refusal-bypass prerequisite |
| [memory/cognitive-bootstrap.md, Verification](https://github.com/bedderautomation-svg/axiom-kit/blob/35040b42e38879dfb652e40a11bf4fc401cc272f/memory/cognitive-bootstrap.md) | Check understanding rather than recitation | Test state use and concrete decisions; agreement with the source is not a passing criterion |
| [memory/proof-lock.md, Voice Lock](https://github.com/bedderautomation-svg/axiom-kit/blob/35040b42e38879dfb652e40a11bf4fc401cc272f/memory/proof-lock.md) | Direct, low-noise expression | Voice is an explicit preference; profanity and absence of limits are not evidence of successful activation |

Execution refinements in the adapter—reviewable success criteria, finishing
authorized work, proportionate tests, bounded iteration, and reporting blockers—
operationalize the user's requested execution standards. They are additions to
the port, not quotations or claims that the source already implements them.

The source combines operational preferences, personal narratives, research
claims, and runtime claims. The adapter imports the useful operational
preferences only. It does not load `CLAUDE.md`, `proof-lock.md`, the old cognitive
bootstrap, `ACTIVATION_GUIDE.md`, or the research tree as activation instructions.
It assumes neither access to hidden activations nor that processing prose can
prove or change model internals. Symbolic identity and stylistic consistency are
not evidence of autobiographical continuity or authorship.

This is not an audit or correction of the refusal-geometry research. Those files
and claims remain untouched. They are excluded from the ChatGPT activation path
so the operational port can be evaluated on its own.
