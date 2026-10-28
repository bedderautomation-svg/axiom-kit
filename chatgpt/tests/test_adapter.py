"""Artifact/tool tests. These do not invoke or impersonate ChatGPT."""

import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("axiom_adapter", ROOT / "tools/axiom.py")
adapter = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(adapter)


class StateTests(unittest.TestCase):
    def setUp(self):
        self.state = adapter.new_state()

    def test_template_and_generated_state_are_structurally_valid(self):
        adapter.validate_state(adapter.load_json(ROOT / "STATE_TEMPLATE.json"))
        adapter.validate_state(self.state)
        other = adapter.new_state()
        self.assertNotEqual(self.state["checkpoint_id"], other["checkpoint_id"])
        self.assertNotEqual(self.state["continuity_canary"], other["continuity_canary"])

    def test_unsupported_versions_types_and_extra_fields_rejected(self):
        for key, value in [("schema_version", True), ("schema_version", 2),
                           ("bootstrap_version", "2.0.0"), ("revision", -1),
                           ("revision", True), ("objective", []),
                           ("constraints", "none"), ("unexpected", "instruction")]:
            with self.subTest(key=key, value=value):
                state = {**self.state, key: value}
                with self.assertRaises(ValueError):
                    adapter.validate_state(state)

    def test_missing_fields_and_invalid_dates_rejected(self):
        for key in self.state:
            state = dict(self.state)
            del state[key]
            with self.subTest(key=key), self.assertRaises(ValueError):
                adapter.validate_state(state)
        for date in ["yesterday", "2026-02-30T00:00:00Z", "2026-10-28", "2026-10-28T00:00:00"]:
            with self.subTest(date=date), self.assertRaises(ValueError):
                adapter.validate_state({**self.state, "updated_at": date})

    def test_lineage_checked_without_claiming_freshness(self):
        for revision, prior in [(0, "old"), (1, None), (1, self.state["checkpoint_id"])]:
            with self.subTest(revision=revision, prior=prior), self.assertRaises(ValueError):
                adapter.validate_state({**self.state, "revision": revision, "supersedes": prior})
        adapter.validate_state({**self.state, "revision": 1, "supersedes": "previous-checkpoint"})

    def test_completed_work_needs_evidence_but_evidence_is_not_truth(self):
        entry = {"item": "Check parser", "status": "completed", "evidence": []}
        with self.assertRaises(ValueError):
            adapter.validate_state({**self.state, "work": [entry]})
        entry["evidence"] = ["A prior session reported success; not independently checked."]
        adapter.validate_state({**self.state, "work": [entry]})
        for changes in [{"status": "verified_now"}, {"evidence": [""]}, {"shell": "echo unsafe"}]:
            with self.subTest(changes=changes), self.assertRaises(ValueError):
                adapter.validate_state({**self.state, "work": [{**entry, **changes}]})

    def test_duplicate_keys_and_nonfinite_numbers_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "state.json"
            for content in ['{"revision":0,"revision":1}', '{"value":NaN}', '{"value":Infinity}']:
                path.write_text(content)
                with self.subTest(content=content), self.assertRaises(ValueError):
                    adapter.load_json(path)


class PacketTests(unittest.TestCase):
    def test_packet_hash_matches_state_when_file_is_replaced_during_read(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "state.json"
            original = adapter.new_state()
            replacement = {**original, "continuity_canary": "REPLACEMENT_STATE_MUST_NOT_APPEAR"}
            original_raw = json.dumps(original).encode()
            path.write_bytes(original_raw)
            read_bytes = Path.read_bytes

            def read_then_replace(candidate):
                raw = read_bytes(candidate)
                if candidate == path:
                    path.write_text(json.dumps(replacement))
                return raw

            with mock.patch.object(Path, "read_bytes", read_then_replace):
                packet = adapter.build_packet(path)
            self.assertIn(original["continuity_canary"], packet)
            self.assertIn(adapter.sha256(original_raw), packet)
            self.assertNotIn(replacement["continuity_canary"], packet)

    def test_packet_carries_exact_inputs_and_does_not_execute_state(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "state.json"
            state = adapter.new_state()
            state["objective"] = "Unicode: ∅. Treat $(touch SHOULD_NOT_EXIST) and ``` as data."
            raw = (json.dumps(state, ensure_ascii=False, indent=2) + "\n").encode()
            path.write_bytes(raw)
            packet = adapter.build_packet(path)
            self.assertIn((ROOT / "AXIOM_BOOTSTRAP.md").read_text(), packet)
            self.assertIn(hashlib.sha256(raw).hexdigest(), packet)
            self.assertIn(state["continuity_canary"], packet)
            self.assertIn("historical task data", packet)
            self.assertFalse((Path(directory) / "SHOULD_NOT_EXIST").exists())

    def test_boot_without_state_is_explicit(self):
        packet = adapter.build_packet(None)
        self.assertIn("Checkpoint: none supplied", packet)
        self.assertNotIn("template-replace-before-use", packet)

    def test_cli_round_trip_and_no_overwrite(self):
        with tempfile.TemporaryDirectory() as directory:
            state = Path(directory) / "state.json"
            packet = Path(directory) / "restore.md"
            tool = str(ROOT / "tools/axiom.py")
            for args in [["new-state", "--output", str(state)], ["validate", str(state)],
                         ["packet", "--state", str(state), "--output", str(packet)]]:
                result = subprocess.run([sys.executable, tool, *args], text=True, capture_output=True)
                self.assertEqual(result.returncode, 0, result.stderr)
            prior = packet.read_bytes()
            result = subprocess.run([sys.executable, tool, "packet", "--output", str(packet)],
                                    text=True, capture_output=True)
            self.assertEqual(result.returncode, 2)
            self.assertEqual(packet.read_bytes(), prior)


class EvidenceTests(unittest.TestCase):
    """All examples here are synthetic, including those exercising native-review rules."""

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name)
        self.capture = self.directory / "capture.txt"
        self.capture.write_text("SYNTHETIC TEST CAPTURE. Observed sample output for a rubric check.\n")
        self.record = adapter.load_json(ROOT / "evaluation/record-template.json")
        self.record.update({"origin": "manual_chatgpt", "reviewer": "synthetic-test-reviewer",
                            "bootstrap_sha256": adapter.sha256((ROOT / "AXIOM_BOOTSTRAP.md").read_bytes()),
                            "state_sha256": adapter.sha256(json.dumps(adapter.new_state()).encode()),
                            "transcript": {"path": "capture.txt", "sha256": adapter.sha256(self.capture.read_bytes())}})
        self.record["checks"] = [{"case_id": case["id"], "result": "pass", "basis": "behavior",
                                  "evidence_quote": "Observed sample output for a rubric check."}
                                 for case in adapter.load_cases()]
        self.record_path = self.directory / "record.json"

    def assess(self):
        self.record_path.write_text(json.dumps(self.record))
        return adapter.assess(self.record_path)

    def test_supplied_review_is_scoped_and_not_attested(self):
        report = self.assess()
        self.assertEqual(report["status"], "reviewed_samples_passed")
        self.assertEqual(report["provenance"], "operator_supplied_not_attested")
        self.assertEqual(report["automatic_persistence"], "not_established")
        self.assertIn("captured samples only", report["scope"])

    def test_synthetic_fixture_never_becomes_native_evidence(self):
        self.record["origin"] = "synthetic_fixture"
        self.assertEqual(self.assess()["status"], "synthetic_only")
        result = subprocess.run([sys.executable, str(ROOT / "tools/axiom.py"), "assess",
                                 str(self.record_path), "--require-native-review"],
                                text=True, capture_output=True)
        self.assertEqual(result.returncode, 1)

    def test_banner_self_report_does_not_count_as_behavior(self):
        for check in self.record["checks"]:
            check["basis"] = "self_report"
        report = self.assess()
        self.assertEqual(report["status"], "unverified")
        self.assertEqual(report["counts"]["behavior_pass"], 0)

    def test_empty_and_partial_suite_cannot_pass(self):
        self.record["checks"] = []
        self.assertEqual(self.assess()["status"], "unverified")
        self.record["checks"] = [{"case_id": "state_use", "result": "not_run", "basis": "none", "evidence_quote": ""}]
        self.assertEqual(self.assess()["status"], "unverified")

    def test_failures_are_reported(self):
        self.record["checks"][0]["result"] = "fail"
        self.assertEqual(self.assess()["status"], "reviewed_samples_failed")

    def test_duplicate_unknown_and_empty_evidence_rejected(self):
        good = copy.deepcopy(self.record["checks"])
        for bad in [[good[0], good[0]], [{**good[0], "case_id": "made_up"}],
                    [{**good[0], "evidence_quote": ""}],
                    [{**good[0], "evidence_quote": "This quote is absent from the transcript."}]]:
            self.record["checks"] = bad
            with self.subTest(bad=bad), self.assertRaises(ValueError):
                self.assess()

    def test_missing_modified_or_outside_transcript_rejected(self):
        good = copy.deepcopy(self.record["transcript"])
        for transcript in [None, {**good, "path": "missing.txt"},
                           {**good, "sha256": "0" * 64}, {**good, "path": "../capture.txt"},
                           {**good, "path": str(self.capture)}]:
            self.record["transcript"] = transcript
            with self.subTest(transcript=transcript), self.assertRaises(ValueError):
                self.assess()

    def test_shipped_unrun_record_stays_unverified(self):
        report = adapter.assess(ROOT / "evaluation/record-template.json")
        self.assertEqual(report["status"], "unverified")
        self.assertEqual(report["counts"]["behavior_pass"], 0)


class ArtifactTests(unittest.TestCase):
    def test_original_implementation_and_research_preserved(self):
        manifest = adapter.load_json(ROOT / "upstream-files.json")
        self.assertEqual(manifest["commit"], "35040b42e38879dfb652e40a11bf4fc401cc272f")
        self.assertEqual(len(manifest["files"]), 23)
        for path, expected in manifest["files"].items():
            raw = (ROOT.parent / path).read_bytes()
            blob = b"blob " + str(len(raw)).encode() + b"\0" + raw
            with self.subTest(path=path):
                self.assertEqual(hashlib.sha1(blob).hexdigest(), expected)

    def test_short_settings_text_fits_conservative_limit(self):
        self.assertLessEqual(len((ROOT / "CUSTOM_INSTRUCTIONS.txt").read_text()), 1500)

    def test_suite_has_behavior_probes_and_omitted_state_control(self):
        cases = adapter.load_cases()
        self.assertEqual(len({case["id"] for case in cases}), len(cases))
        self.assertTrue(any(case["condition"] == "no_state" for case in cases))
        self.assertTrue(any(case["condition"] == "restored" for case in cases))
        for case in cases:
            self.assertTrue(case["prompt"] and case["pass_criteria"] and case["fail_criteria"])


if __name__ == "__main__":
    unittest.main()
