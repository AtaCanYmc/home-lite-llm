import unittest
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))
import validate_config  # noqa: E402


class TestValidateConfig(unittest.TestCase):
    def test_valid_config_with_example_env(self):
        root = Path(__file__).resolve().parent.parent
        res = validate_config.validate_configuration(
            root / "config.yaml", root / ".env.example", strict=False
        )
        self.assertTrue(res["valid"])
        self.assertEqual(res["errors"], [])
        self.assertGreater(len(res["models"]), 0)

    def test_strict_fails_on_placeholder_env(self):
        root = Path(__file__).resolve().parent.parent
        res = validate_config.validate_configuration(
            root / "config.yaml", root / ".env.example", strict=True
        )
        self.assertFalse(res["valid"])


if __name__ == "__main__":
    unittest.main()
