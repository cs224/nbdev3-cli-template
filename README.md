# nbdev2 CLI Copier Template

This is a Copier template for a minimal nbdev2 project with a Hello World CLI.

## Install uv (one-time setup)

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Add uv to your PATH (example for a typical shell):

```bash
line='export PATH="$HOME/.local/bin:$PATH"'
file="$HOME/.bashrc"
grep -qxF "$line" "$file" || printf '\n%s\n' "$line" >> "$file"
source "$HOME/.bashrc"
```

Install Python 3.12 via uv and set it as the default:

```bash
uv python install 3.12 --default
```

## Generate a new project

```bash
uvx copier copy template_nbdev2 <dest>
```

For local usage in this repo, you can also run:

```bash
uvx copier copy ./nbdev2-cli-template <dest>
```

### Passing parameters on the command line

Use `-d KEY=VALUE` to override defaults (repeatable). Missing values fall back to defaults. Derived defaults (like `package_name` from `project_name`) are computed from the provided values, so `-d project_name=my-cli` will result in `package_name=my_cli` unless you override it explicitly.

```bash
# override a few values; the rest use defaults
uvx copier copy ./nbdev2-cli-template <dest> \
  -d project_name=my-cli \
  -d package_name=my_cli \
  -d cli_name=my-cli
```

To provide all parameters explicitly:

```bash
uvx copier copy ./nbdev2-cli-template <dest> \
  -d project_name=my-cli \
  -d package_name=my_cli \
  -d cli_name=my-cli \
  -d description="My CLI" \
  -d author_name="Your Name" \
  -d author_email="you@example.com" \
  -d repo_slug="your-org/my-cli" \
  -d min_python=3.12
```

If you prefer a persistent install, you can also do:

```bash
uv tool install copier
copier copy ./nbdev2-cli-template <dest>
```

`uv tool install` installs a tool into a **global, user-level uv tools environment** (not the current project’s `.venv`). This makes the command available on your PATH across projects.
e.g.
```bash
copier copy --defaults ./nbdev2-cli-template ./_tmp_hello_project
```

## Run the CLI

```bash
uv run <cli_name>
uv run <cli_name> --name Alice
uv run python -m <package_name> --name Alice
```

## Run tests

```bash
uv run pytest
```

## Smoke test (template repo)

```bash
bash nbdev2-cli-template/smoke_test.sh
```

## Notes

- This template uses nbdev2 notebooks in `nbs/` and exports Python modules via `nbdev_export`.
- Avoid `nbdev_prepare`; it overwrites `README.md`.
