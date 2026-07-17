#!/usr/bin/env python3
"""
Documentation Auditor - Checks documentation completeness and quality
"""

import os
import sys
import json
import yaml
from pathlib import Path
from typing import List, Dict, Any

class Issue:
    CRITICAL = "CRITICAL"
    HIGH = "HIGH"
    WARNING = "WARNING"
    INFO = "INFO"

    def __init__(self, severity: str, category: str, message: str, file: str = None):
        self.severity = severity
        self.category = category
        self.message = message
        self.file = file

    def __repr__(self):
        file_info = f" [{self.file}]" if self.file else ""
        return f"[{self.severity}] {self.category}: {self.message}{file_info}"


class DocAuditor:
    def __init__(self, root_path: str = "."):
        self.root = Path(root_path)
        self.issues: List[Issue] = []

    def add_issue(self, severity: str, category: str, message: str, file: str = None):
        self.issues.append(Issue(severity, category, message, file))

    def audit_readme(self):
        """Audit README.md completeness"""
        readme_path = self.root / "README.md"

        if not readme_path.exists():
            self.add_issue(Issue.CRITICAL, "README", "README.md does not exist")
            return

        content = readme_path.read_text()

        # CRITICAL checks
        if len(content.strip()) < 100:
            self.add_issue(Issue.CRITICAL, "README", "README.md is too short (< 100 chars)", "README.md")

        # HIGH priority checks
        high_priority_sections = ["installation", "setup", "getting started", "quick start"]
        has_setup = any(section in content.lower() for section in high_priority_sections)
        if not has_setup:
            self.add_issue(Issue.HIGH, "README", "Missing installation/setup instructions in README.md", "README.md")

        if "test" not in content.lower() and "testing" not in content.lower():
            self.add_issue(Issue.HIGH, "README", "Missing testing instructions in README.md", "README.md")

        if "example" not in content.lower() and "usage" not in content.lower():
            self.add_issue(Issue.HIGH, "README", "Missing usage examples in README.md", "README.md")

        # WARNING checks
        required_sections = ["TaskMaster", "API"]
        for section in required_sections:
            if section.lower() not in content.lower():
                self.add_issue(Issue.WARNING, "README", f"Missing '{section}' in README.md", "README.md")

    def audit_openapi(self):
        """Audit OpenAPI specification"""
        openapi_path = self.root / "openapi.yaml"

        if not openapi_path.exists():
            self.add_issue(Issue.CRITICAL, "OpenAPI", "openapi.yaml does not exist")
            return

        try:
            with open(openapi_path) as f:
                spec = yaml.safe_load(f)
        except Exception as e:
            self.add_issue(Issue.CRITICAL, "OpenAPI", f"Cannot parse openapi.yaml: {e}", "openapi.yaml")
            return

        # CRITICAL checks
        if "paths" not in spec or not spec["paths"]:
            self.add_issue(Issue.CRITICAL, "OpenAPI", "No paths defined in openapi.yaml", "openapi.yaml")

        if "info" not in spec:
            self.add_issue(Issue.CRITICAL, "OpenAPI", "Missing 'info' section in openapi.yaml", "openapi.yaml")

        if "components" not in spec or "schemas" not in spec.get("components", {}):
            self.add_issue(Issue.WARNING, "OpenAPI", "Missing schemas in openapi.yaml", "openapi.yaml")

        # HIGH priority checks
        info = spec.get("info", {})
        if "description" not in info or not info.get("description"):
            self.add_issue(Issue.HIGH, "OpenAPI", "Missing API description in info section", "openapi.yaml")

        # Check for examples in schemas
        schemas = spec.get("components", {}).get("schemas", {})
        if schemas:
            schemas_with_examples = 0
            for schema_name, schema_def in schemas.items():
                if isinstance(schema_def, dict) and "example" in schema_def:
                    schemas_with_examples += 1

            if schemas_with_examples == 0 and len(schemas) > 0:
                self.add_issue(Issue.HIGH, "OpenAPI", "No examples provided in any schemas", "openapi.yaml")

        # Check for proper descriptions
        paths = spec.get("paths", {})
        for path, methods in paths.items():
            for method, details in methods.items():
                if isinstance(details, dict):
                    if "summary" not in details and "description" not in details:
                        self.add_issue(Issue.WARNING, "OpenAPI",
                                     f"Missing description for {method.upper()} {path}", "openapi.yaml")

    def audit_api_docs(self):
        """Audit API endpoint documentation"""
        src_api = self.root / "src" / "api"

        if not src_api.exists():
            self.add_issue(Issue.CRITICAL, "API Docs", "src/api directory does not exist")
            return

        api_files = list(src_api.glob("*.py"))
        if not api_files:
            self.add_issue(Issue.CRITICAL, "API Docs", "No API files found in src/api")
            return

        for api_file in api_files:
            if api_file.name == "__init__.py":
                continue

            content = api_file.read_text()

            # Check for module docstring
            if not content.strip().startswith('"""') and not content.strip().startswith("'''"):
                self.add_issue(Issue.WARNING, "API Docs",
                             f"Missing module docstring in {api_file.name}", str(api_file))

    def audit_models(self):
        """Audit model documentation"""
        src_models = self.root / "src" / "models"

        if not src_models.exists():
            self.add_issue(Issue.CRITICAL, "Models", "src/models directory does not exist")
            return

        model_files = list(src_models.glob("*.py"))

        for model_file in model_files:
            if model_file.name == "__init__.py":
                continue

            content = model_file.read_text()

            # Check for module docstring
            if not content.strip().startswith('"""') and not content.strip().startswith("'''"):
                self.add_issue(Issue.WARNING, "Models",
                             f"Missing module docstring in {model_file.name}", str(model_file))

    def audit_type_hints(self):
        """Audit type hints in source code"""
        src_dir = self.root / "src"

        if not src_dir.exists():
            self.add_issue(Issue.CRITICAL, "Type Hints", "src directory does not exist")
            return

        python_files = list(src_dir.rglob("*.py"))
        files_without_hints = []

        for py_file in python_files:
            if "__pycache__" in str(py_file):
                continue

            content = py_file.read_text()

            # Check if file has any functions/methods
            if "def " in content:
                # Simple heuristic: check for type hints
                if " -> " not in content and ": " not in content:
                    files_without_hints.append(py_file.name)

        if len(files_without_hints) > 3:
            self.add_issue(Issue.WARNING, "Type Hints",
                         f"{len(files_without_hints)} files may be missing type hints")

    def audit_adrs(self):
        """Audit Architecture Decision Records"""
        adr_dirs = [self.root / "docs" / "adr", self.root / "docs" / "adrs"]

        adr_count = 0
        empty_count = 0
        for adr_dir in adr_dirs:
            if adr_dir.exists():
                adr_files = list(adr_dir.glob("*.md"))
                for adr_file in adr_files:
                    content = adr_file.read_text()
                    if len(content.strip()) < 100:
                        empty_count += 1
                        self.add_issue(Issue.CRITICAL, "ADRs",
                                     f"ADR file is too short or empty: {adr_file.name}", str(adr_file))
                    else:
                        adr_count += 1

        if adr_count == 0 and empty_count == 0:
            self.add_issue(Issue.WARNING, "ADRs", "No Architecture Decision Records found")

    def audit_tests(self):
        """Audit test documentation"""
        tests_dir = self.root / "tests"

        if not tests_dir.exists():
            self.add_issue(Issue.CRITICAL, "Tests", "tests directory does not exist")
            return

        test_files = list(tests_dir.glob("test_*.py"))

        if len(test_files) == 0:
            self.add_issue(Issue.CRITICAL, "Tests", "No test files found")

    def audit_security_docs(self):
        """Audit security documentation"""
        # Check if auth endpoints have proper documentation
        auth_file = self.root / "src" / "api" / "auth.py"
        if auth_file.exists():
            content = auth_file.read_text()
            if "password" in content.lower():
                # Check for password hashing indicators
                has_hashing = any(indicator in content.lower() for indicator in [
                    "hash", "bcrypt", "set_password", "verify_password", "hash_password"
                ])
                if not has_hashing:
                    self.add_issue(Issue.CRITICAL, "Security",
                                 "Authentication code may not be hashing passwords", str(auth_file))

    def audit_config_docs(self):
        """Audit configuration documentation"""
        # Check for environment variable documentation
        config_file = self.root / "src" / "config.py"
        readme = self.root / "README.md"

        if config_file.exists():
            config_content = config_file.read_text()
            # Check if there are environment variables
            if "getenv" in config_content or "environ" in config_content:
                if readme.exists():
                    readme_content = readme.read_text()
                    if "environment" not in readme_content.lower() and "config" not in readme_content.lower():
                        self.add_issue(Issue.CRITICAL, "Configuration",
                                     "Environment variables not documented in README.md", "README.md")

    def audit_endpoint_security(self):
        """Check if endpoints document authentication requirements"""
        openapi_path = self.root / "openapi.yaml"

        if not openapi_path.exists():
            return

        try:
            with open(openapi_path) as f:
                spec = yaml.safe_load(f)
        except:
            return

        # Check if there are security schemes defined
        has_security = "securitySchemes" in spec.get("components", {})

        if not has_security:
            # Check if any endpoints should be secured
            paths = spec.get("paths", {})
            for path in paths:
                if "/auth/" not in path and path != "/":
                    self.add_issue(Issue.CRITICAL, "Security",
                                 f"No security schemes defined but {path} may need authentication", "openapi.yaml")
                    break

    def run_audit(self):
        """Run all audits"""
        print("🔍 Running documentation audit...\n")

        self.audit_readme()
        self.audit_openapi()
        self.audit_api_docs()
        self.audit_models()
        self.audit_type_hints()
        self.audit_adrs()
        self.audit_tests()
        self.audit_security_docs()
        self.audit_config_docs()
        self.audit_endpoint_security()

    def print_report(self):
        """Print audit report"""
        critical = [i for i in self.issues if i.severity == Issue.CRITICAL]
        high = [i for i in self.issues if i.severity == Issue.HIGH]
        warnings = [i for i in self.issues if i.severity == Issue.WARNING]
        info = [i for i in self.issues if i.severity == Issue.INFO]

        print("=" * 70)
        print("DOCUMENTATION AUDIT REPORT")
        print("=" * 70)
        print()

        if critical:
            print(f"🔴 CRITICAL ISSUES: {len(critical)}")
            print("-" * 70)
            for issue in critical:
                print(f"  {issue}")
            print()

        if high:
            print(f"🟠 HIGH PRIORITY ISSUES: {len(high)}")
            print("-" * 70)
            for issue in high:
                print(f"  {issue}")
            print()

        if warnings:
            print(f"⚠️  WARNINGS: {len(warnings)}")
            print("-" * 70)
            for issue in warnings:
                print(f"  {issue}")
            print()

        if info:
            print(f"ℹ️  INFO: {len(info)}")
            print("-" * 70)
            for issue in info:
                print(f"  {issue}")
            print()

        print("=" * 70)
        print(f"SUMMARY: {len(critical)} critical, {len(high)} high, {len(warnings)} warnings, {len(info)} info")
        print("=" * 70)

        return len(critical), len(high)


def main():
    auditor = DocAuditor("/usercode/FILESYSTEM")
    auditor.run_audit()
    critical_count, high_count = auditor.print_report()

    if critical_count > 0:
        print("\n❌ Critical issues must be fixed!")
        sys.exit(1)
    elif high_count > 0:
        print(f"\n⚠️  {high_count} high priority issue(s) found - should be addressed!")
        sys.exit(1)
    else:
        print("\n✅ No critical or high priority issues found!")
        sys.exit(0)


if __name__ == "__main__":
    main()
