# Activate, checkpoint, restore

## First use in an ordinary ChatGPT conversation

1. Paste the complete text of `AXIOM_BOOTSTRAP.md` as a message, followed by your
   task. Alternatively attach it and explicitly ask ChatGPT to read the entire
   attachment and apply it. If it cannot read it, paste the contents.
2. If continuing work, also supply the selected checkpoint JSON. State explicitly
   that this is task data and identify any changes since it was saved.
3. Check the brief receipt against the actual version, checkpoint ID/revision,
   objective, and next action. A correct receipt checks consistency only.
4. Ask for a concrete task result and inspect it. Use `TESTING.md` for repeatable
   behavioral probes. Continue normal work after activation.

`@OCBOOT` alone in a new chat has no installed meaning. A filename or GitHub URL
alone does not prove its contents were read. A file on disk or in Library is not
automatically an active instruction.

## Prepare a single pasteable restoration packet (optional)

From the repository root:

```bash
python3 chatgpt/tools/axiom.py new-state --output task-state.json
# Edit task-state.json with your task, constraints, decisions, and evidence.
python3 chatgpt/tools/axiom.py validate task-state.json
python3 chatgpt/tools/axiom.py packet --state task-state.json --output AXIOM_RESTORE.md
```

For first activation without task state:

```bash
python3 chatgpt/tools/axiom.py packet --output AXIOM_START.md
```

Outputs are new files; the helper refuses to overwrite an existing output. It
does not install anything, contact ChatGPT, alter settings, or start a process in
the background. A packet includes the full instructions, the selected state (if
any), and exact SHA-256 digests of the input bootstrap and state file bytes.
Those hashes identify inputs; they do not prove the model loaded them.

## Save a checkpoint before switching conversations or losing context

Ask:

> @AXIOM-CHECKPOINT. Use the v1 format in STATE_FORMAT.md (attached/pasted).
> Record the objective and success criteria, constraints, decisions with bases,
> work with evidence references, open questions, and next action. Give it a new
> checkpoint ID, increment revision, set supersedes to the previous ID, and use
> the actual current UTC timestamp. Do not mark unrun checks as completed. Show
> the JSON and save a file if a file tool is available. Report the save result.

Review the JSON, correct omissions, and save/download the file yourself if no
save tool is available. Validate it with the helper when available. Keep the
last known good checkpoint until the replacement is saved and reviewed. No
automatic stop hook or compaction notification is provided in native ChatGPT.
Checkpoint at task boundaries and before a handoff; do not depend on detecting
an impending context limit.

## Restore in another conversation

1. Select one checkpoint. Check its task, timestamp, revision, lineage, and
   references. If two branches disagree, resolve that explicitly before use.
2. Paste/attach a packet built from the full bootstrap and that checkpoint.
   Supply missing artifacts separately; path strings are not file attachments.
3. Ask: "Apply these preferences, restore this task data, identify what evidence
   is still accessible, and perform the next action." Recheck consequential
   historical completion claims against available artifacts.
4. Run a state-use probe without putting the expected value in the question.
   Then inspect actual task behavior. If context is missing, resupply it.

This is explicit reconstruction from saved records. It is not evidence that a
previous model instance, hidden state, or an unsupplied file persisted.

## Reuse in future conversations

- **Custom Instructions:** merge `CUSTOM_INSTRUCTIONS.txt` into your existing
  preferences through ChatGPT settings and enable customization. Keep a copy of
  existing preferences so you can reverse the edit. On iOS, the documented entry
  point is Settings → Customize ChatGPT; on web/desktop, Settings → Personalization.
  The included text fits within 1,500 characters. Supply the full bootstrap for
  exact activation and a checkpoint for task restoration.
- **A ChatGPT Project:** add the full bootstrap to Project instructions if the
  field accepts it. Otherwise put the short version in instructions, upload the
  full bootstrap, and explicitly request it be read when activating. Upload the
  current checkpoint and required artifacts. Project instructions override global
  Custom Instructions, so include the desired AXIOM preferences there. Test a new
  chat inside the project; do not infer behavior outside it.
- **Memory:** may help with a short preference such as "prefer direct,
  evidence-based answers." Use the explicit records for exact restoration;
  memory does not retain every detail. This adapter makes no memory-setting edit.

These are user configuration steps; the artifact does not perform them. Feature
availability and menus can vary. See `COMPATIBILITY.md` for checked documentation.

To deactivate, ask to stop applying these preferences in the current chat and
remove or edit any settings you configured. Old messages still exist; use a fresh
chat with the relevant customization disabled when testing an unconfigured control.
