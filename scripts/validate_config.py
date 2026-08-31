#!/usr/bin/env python3
"""
LiteLLM Configuration Validator
Validates config.yaml structure, model definitions, router settings,
and cross-checks environment variable references with .env.
"""

import argparse
import json
import os
import sys
from pathlib import Path

# ANSI Color Codes
GREEN = "\033[92m"
YELLOW = "\033[93m"
RED = "\033[91m"
CYAN = "\033[96m"
BOLD = "\033[1m"
DIM = "\033[2m"
RESET = "\033[0m"


def parse_simple_yaml(text: str) -> dict:
    """Lightweight pure-python parser for standard LiteLLM YAML configuration."""
    data = {}
    current_section = None
    current_model = None
    current_map = None

    lines = text.splitlines()
    for raw_line in lines:
        line = raw_line.rstrip()
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue

        indent = len(line) - len(line.lstrip())

        # Top-level keys (indent 0)
        if indent == 0 and ":" in stripped:
            key = stripped.split(":", 1)[0].strip()
            val = stripped.split(":", 1)[1].strip()
            current_section = key
            current_model = None
            current_map = None
            if key == "model_list":
                data[key] = []
            elif key in ("router_settings", "general_settings"):
                data[key] = {}
            elif val:
                data[key] = val
            continue

        # model_list items
        if current_section == "model_list":
            if stripped.startswith("- "):
                # New model item
                current_model = {}
                data["model_list"].append(current_model)
                current_map = None
                rest = stripped[2:].strip()
                if ":" in rest:
                    k, v = rest.split(":", 1)
                    k, v = k.strip(), v.strip().strip("'\"")
                    if k == "litellm_params":
                        current_model["litellm_params"] = {}
                        current_map = current_model["litellm_params"]
                    else:
                        current_model[k] = v
            elif current_model is not None:
                if ":" in stripped:
                    k, v = stripped.split(":", 1)
                    k = k.strip()
                    v = v.strip().strip("'\"")
                    if k == "litellm_params":
                        current_model["litellm_params"] = {}
                        current_map = current_model["litellm_params"]
                    elif current_map is not None and indent >= 4:
                        if v.isdigit():
                            current_map[k] = int(v)
                        elif v.lower() == "true":
                            current_map[k] = True
                        elif v.lower() == "false":
                            current_map[k] = False
                        else:
                            current_map[k] = v
                    else:
                        current_model[k] = v

        # router_settings or general_settings
        elif current_section in ("router_settings", "general_settings"):
            sec = data[current_section]
            if stripped.startswith("- ") and ":" in stripped:
                # e.g. fallbacks list
                k, v = stripped[2:].split(":", 1)
                k = k.strip()
                v = v.strip()
                if "fallbacks" not in sec:
                    sec["fallbacks"] = []
                if v.startswith("[") and v.endswith("]"):
                    items = [x.strip().strip("'\"") for x in v[1:-1].split(",") if x.strip()]
                    sec["fallbacks"].append({k: items})
            elif ":" in stripped:
                k, v = stripped.split(":", 1)
                k = k.strip()
                v = v.strip().strip("'\"")
                if v.isdigit():
                    sec[k] = int(v)
                elif v.lower() == "true":
                    sec[k] = True
                elif v.lower() == "false":
                    sec[k] = False
                elif v:
                    sec[k] = v

    return data


def load_yaml(file_path: Path):
    """Load YAML file using PyYAML if available, or lightweight pure-Python fallback."""
    try:
        import yaml
        with open(file_path, "r", encoding="utf-8") as f:
            return yaml.safe_load(f), None
    except ImportError:
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()
            parsed = parse_simple_yaml(content)
            return parsed, None
        except (ValueError, TypeError, KeyError, IndexError, OSError) as e:
            return None, f"Fallback YAML parsing error: {e}"
    except (yaml.YAMLError, OSError) as e:
        return None, str(e)




def parse_env_file(env_path: Path) -> dict:
    """Parse key-value pairs from a .env file."""
    env_vars = {}
    if not env_path.is_file():
        return env_vars

    with open(env_path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if "=" in line:
                key, val = line.split("=", 1)
                key = key.strip()
                val = val.strip().strip("'\"")
                env_vars[key] = val
    return env_vars


def is_placeholder_value(val: str) -> bool:
    """Check if an environment variable value is a default placeholder."""
    if not val:
        return True
    lower = val.lower()
    placeholders = [
        "your_",
        "_here",
        "sk-your-secure",
        "your-resource-name",
        "your_openai_api_key",
        "your_anthropic_api_key",
        "your_gemini_api_key",
        "your_deepseek_api_key",
        "your_postgres_password",
        "your_grafana_password",
        "example",
        "changeme",
        "admin",
    ]
    return any(p in lower for p in placeholders)


def extract_env_vars_from_config(config_data) -> set:
    """Recursively extract all 'os.environ/VAR_NAME' references from config."""
    referenced_vars = set()

    def search_obj(obj):
        if isinstance(obj, str):
            if obj.startswith("os.environ/"):
                var_name = obj.split("os.environ/", 1)[1].strip()
                referenced_vars.add(var_name)
        elif isinstance(obj, dict):
            for v in obj.values():
                search_obj(v)
        elif isinstance(obj, list):
            for item in obj:
                search_obj(item)

    search_obj(config_data)
    return referenced_vars


def validate_configuration(config_path: Path, env_path: Path, strict: bool = False) -> dict:
    """Perform comprehensive validation of config.yaml and environment."""
    results = {
        "valid": True,
        "config_file": str(config_path),
        "env_file": str(env_path) if env_path.exists() else None,
        "errors": [],
        "warnings": [],
        "models_count": 0,
        "models": [],
        "fallbacks": [],
        "env_status": {},
    }

    if not config_path.is_file():
        results["valid"] = False
        results["errors"].append(f"Configuration file not found: {config_path}")
        return results

    config_data, parse_err = load_yaml(config_path)

    if parse_err and config_data is None:
        if "PyYAML is not installed" in parse_err:
            results["warnings"].append(parse_err)
        else:
            results["valid"] = False
            results["errors"].append(f"YAML Syntax Error: {parse_err}")
            return results

    if config_data is not None and not isinstance(config_data, dict):
        results["valid"] = False
        results["errors"].append("Root of config.yaml must be a dictionary/mapping.")
        return results

    if config_data is None:
        # PyYAML not available or empty, return partial report
        return results


    # 1. Validate model_list
    model_list = config_data.get("model_list")
    if not model_list:
        results["valid"] = False
        results["errors"].append("Missing or empty 'model_list' section in config.yaml.")
    elif not isinstance(model_list, list):
        results["valid"] = False
        results["errors"].append("'model_list' must be a list of model definitions.")
    else:
        results["models_count"] = len(model_list)
        configured_model_names = set()

        for idx, item in enumerate(model_list):
            if not isinstance(item, dict):
                results["errors"].append(f"Model item #{idx + 1} is not a valid YAML object.")
                results["valid"] = False
                continue

            name = item.get("model_name")
            params = item.get("litellm_params")

            if not name:
                results["errors"].append(f"Model item #{idx + 1} is missing 'model_name'.")
                results["valid"] = False
            else:
                configured_model_names.add(name)

            if not params or not isinstance(params, dict):
                results["errors"].append(f"Model '{name or f'#{idx+1}'}' is missing 'litellm_params'.")
                results["valid"] = False
            else:
                target_model = params.get("model")
                if not target_model:
                    results["errors"].append(f"Model '{name}' litellm_params is missing 'model' target string.")
                    results["valid"] = False

                results["models"].append({
                    "name": name,
                    "target": target_model,
                    "api_key_ref": params.get("api_key"),
                    "api_base": params.get("api_base"),
                    "rpm": params.get("rpm"),
                })

    # 2. Validate router_settings (fallbacks & retries)
    router = config_data.get("router_settings", {})
    if isinstance(router, dict):
        fallbacks = router.get("fallbacks", [])
        if isinstance(fallbacks, list):
            for fb in fallbacks:
                if isinstance(fb, dict):
                    for primary, targets in fb.items():
                        results["fallbacks"].append({"primary": primary, "targets": targets})
                        if primary not in configured_model_names:
                            results["warnings"].append(
                                f"Router fallback primary model '{primary}' is not defined in model_list."
                            )
                        if isinstance(targets, list):
                            for t in targets:
                                if t not in configured_model_names:
                                    results["warnings"].append(
                                        f"Router fallback target '{t}' (for '{primary}') is not in model_list."
                                    )

    # 3. Environment Variables Validation
    referenced_vars = extract_env_vars_from_config(config_data)
    env_vars_file = parse_env_file(env_path)

    for var in sorted(referenced_vars):
        val = env_vars_file.get(var) or os.environ.get(var)
        if val is None:
            status = "MISSING"
            results["warnings"].append(f"Referenced environment variable '{var}' is not defined in .env or OS env.")
            if strict:
                results["valid"] = False
        elif is_placeholder_value(val):
            status = "PLACEHOLDER"
            results["warnings"].append(f"Environment variable '{var}' still has default placeholder value: '{val}'")
            if strict:
                results["valid"] = False
        else:
            status = "SET"

        results["env_status"][var] = {
            "status": status,
            "masked_value": (val[:4] + "..." + val[-4:]) if val and len(val) > 10 else ("***" if val else ""),
        }

    return results


def print_cli_report(results: dict, quiet: bool = False):
    """Print formatted validation report to terminal."""
    if quiet and results["valid"] and not results["errors"]:
        return

    print(f"\n{BOLD}{CYAN}======================================================{RESET}")
    print(f"{BOLD}{CYAN}      LiteLLM Gateway Configuration Validator        {RESET}")
    print(f"{BOLD}{CYAN}======================================================{RESET}\n")

    print(f"{BOLD}📄 Config File:{RESET} {results['config_file']}")
    if results.get("env_file"):
        print(f"{BOLD}🔑 Env File:   {RESET} {results['env_file']}")
    print(f"{BOLD}🤖 Models:     {RESET} {results['models_count']} defined")
    print(f"{BOLD}🔄 Fallbacks:  {RESET} {len(results['fallbacks'])} rules configured\n")

    # Models Summary
    if results["models"]:
        print(f"{BOLD}📋 Configured Models:{RESET}")
        for m in results["models"]:
            key_info = ""
            if m.get("api_key_ref"):
                ref = m["api_key_ref"]
                if str(ref).startswith("os.environ/"):
                    var_name = ref.split("os.environ/", 1)[1]
                    env_st = results["env_status"].get(var_name, {}).get("status", "UNKNOWN")
                    if env_st == "SET":
                        key_info = f" {GREEN}(Key: {var_name} ✔){RESET}"
                    elif env_st == "PLACEHOLDER":
                        key_info = f" {YELLOW}(Key: {var_name} ⚠ placeholder){RESET}"
                    else:
                        key_info = f" {RED}(Key: {var_name} ✖ missing){RESET}"
                else:
                    key_info = f" {DIM}(Key: direct){RESET}"
            elif m.get("api_base"):
                key_info = f" {CYAN}(Local Base: {m['api_base']}){RESET}"

            print(f"  • {BOLD}{m['name']:<24}{RESET} -> {DIM}{m.get('target', 'N/A')}{RESET}{key_info}")
        print()

    # Environment Variables Summary
    if results["env_status"]:
        print(f"{BOLD}🔐 Environment Variables Status:{RESET}")
        for var, details in sorted(results["env_status"].items()):
            st = details["status"]
            if st == "SET":
                print(f"  {GREEN}✔ SET        {RESET} {BOLD}{var:<22}{RESET} [{details['masked_value']}]")
            elif st == "PLACEHOLDER":
                print(f"  {YELLOW}⚠ PLACEHOLDER{RESET} {BOLD}{var:<22}{RESET} (needs real API key)")
            else:
                print(f"  {RED}✖ MISSING    {RESET} {BOLD}{var:<22}{RESET} (not defined in .env)")
        print()

    # Router Fallbacks
    if results["fallbacks"]:
        print(f"{BOLD}🔄 Fallback Failover Chains:{RESET}")
        for fb in results["fallbacks"]:
            targets_str = " -> ".join(fb["targets"]) if isinstance(fb["targets"], list) else str(fb["targets"])
            print(f"  • {BOLD}{fb['primary']}{RESET} ──► {targets_str}")
        print()

    # Warnings
    if results["warnings"]:
        print(f"{BOLD}{YELLOW}⚠️  Warnings ({len(results['warnings'])}):{RESET}")
        for w in results["warnings"]:
            print(f"  {YELLOW}• {w}{RESET}")
        print()

    # Errors
    if results["errors"]:
        print(f"{BOLD}{RED}❌ Errors ({len(results['errors'])}):{RESET}")
        for e in results["errors"]:
            print(f"  {RED}• {e}{RESET}")
        print()

    # Final Verdict
    if results["valid"] and not results["errors"]:
        print(f"{BOLD}{GREEN}✅ Configuration is valid! Ready for deployment.{RESET}\n")
    else:
        print(f"{BOLD}{RED}❌ Configuration has errors that need to be resolved.{RESET}\n")


def main():
    parser = argparse.ArgumentParser(description="Validate LiteLLM configuration and environment variables.")
    parser.add_argument("--config", "-c", type=Path, default=Path("config.yaml"), help="Path to config.yaml")
    parser.add_argument("--env", "-e", type=Path, default=Path(".env"), help="Path to .env file")
    parser.add_argument("--strict", "-s", action="store_true", help="Fail if any referenced API key is unset or placeholder")
    parser.add_argument("--quiet", "-q", action="store_true", help="Quiet mode, only print on error")
    parser.add_argument("--json", "-j", action="store_true", help="Output results in JSON format")

    args = parser.parse_args()

    # Fallback to .env.example if .env doesn't exist
    env_file = args.env
    if not env_file.exists() and Path(".env.example").exists():
        env_file = Path(".env.example")

    results = validate_configuration(args.config, env_file, strict=args.strict)

    if args.json:
        print(json.dumps(results, indent=2))
    else:
        print_cli_report(results, quiet=args.quiet)

    sys.exit(0 if results["valid"] and not results["errors"] else 1)


if __name__ == "__main__":
    main()
