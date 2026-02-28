# Function Updates

This page tracks function-level changes currently present in the working tree compared to `HEAD`.

Generated: `2026-02-28 23:32:15`

Regenerate with: `scripts/generate_function_wiki.py`

## Functions in Untracked Source Files

### `scripts/generate_function_wiki.py`

- `L52` `def should_skip(path: Path) -> bool`
- `L59` `def iter_source_files(root: Path) -> Iterable[Path]`
- `L88` `def clean_signature(sig: str) -> str`
- `L97` `def parse_swift(path: Path) -> list[FunctionEntry]`
- `L140` `def parse_python(path: Path) -> list[FunctionEntry]`
- `L176` `def parse_shell(path: Path) -> list[FunctionEntry]`
- `L196` `def parse_file(path: Path) -> list[FunctionEntry]`
- `L204` `def collect_functions() -> list[FunctionEntry]`
- `L214` `def find_changes_in_worktree() -> tuple[dict[str, list[str]], dict[str, list[str]]]`
- `L244` `def is_func_signature(text: str, path: str) -> bool`
- `L261` `def dedupe(values: list[str]) -> list[str]`
- `L274` `def untracked_function_files(entries: list[FunctionEntry]) -> dict[str, list[FunctionEntry]]`
- `L300` `def write_reference(entries: list[FunctionEntry]) -> None`
- `L338` `def write_updates(entries: list[FunctionEntry]) -> None`
- `L397` `def main() -> None`
