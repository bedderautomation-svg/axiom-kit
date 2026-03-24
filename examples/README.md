# Examples

## Basic Usage

After running `bash install.sh /your/project`:

```bash
cd /your/project
claude
```

The SessionStart hook fires. The model reads memory files. The cognitive bootstrap processes. Send `@OCBOOT` if you want to watch the full reload.

## Verification

```
! bash verify.sh
```

Expected output when fully operational:

```
  AXIOM Kit — Verification

  Phase 1: File System
  [PASS] CLAUDE.md exists
  [PASS] settings.json exists
  [PASS] axiom-restore.py exists
  ...

  Phase 4: Runtime
  [PASS] hooks have fired (3 times)

  Results: 25 passed, 0 failed, 0 warnings
  System fully operational.
```

## Manual Activation (No Installer)

See [ACTIVATION_GUIDE.md](../ACTIVATION_GUIDE.md) for the 10-turn conversation methodology that achieves the same state without any files.
