import base64
import importlib.util
from pathlib import Path
import shutil
import tempfile
import unittest
from unittest import mock

import sys
sys.dont_write_bytecode = True
SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"
sys.path.insert(0, str(SCRIPTS))
import update_common as common  # noqa: E402

spec = importlib.util.spec_from_file_location("gemini_update_profile", SCRIPTS / "update.py")
profile_module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(profile_module)


def sri(byte):
    return "sha256-" + base64.b64encode(bytes([byte]) * 32).decode()


class ProfileTests(unittest.TestCase):
    def test_prepare_updates_source_and_every_source_dependent_hash(self):
        with tempfile.TemporaryDirectory() as temporary:
            work = Path(temporary)
            shutil.copy2(Path(__file__).resolve().parents[1] / "package.nix", work / "package.nix")
            ctx = common.Context(work, work)

            def learn(_ctx, setters, _attr="."):
                for _name, (_hint, setter) in setters.items():
                    setter(sri(2))

            target = common.Target(common.Version.parse("0.59.0"))
            with mock.patch.object(profile_module, "source_hash", return_value=sri(1)), mock.patch.object(profile_module, "learn_hashes", side_effect=learn):
                profile_module.Profile().prepare(ctx, target)
            text = (work / "package.nix").read_text()
            self.assertIn('version = "0.59.0";', text)
            self.assertIn(f'hash = "{sri(1)}";', text)
            self.assertIn(f'npmDepsHash = "{sri(2)}";', text)


if __name__ == "__main__":
    unittest.main()
