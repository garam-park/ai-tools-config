---
name: import-global-skill
description: Import an existing user-level or globally installed Agent Skill into this repository's global-deployment `skills/` catalog. Use only while working in this repository when the user invokes `$import-global-skill` or `/import-global-skill`, asks to bring, copy, adopt, vendor, or customize a global skill, or wants a global skill made reproducible through this project.
---

# Import Global Skill

Bring one global skill into this repository without overwriting project files or copying this project's own installed symlinks back into itself.

## Resolve the request

1. Identify the source skill name. If it is missing or more than one skill is plausible, ask one concise question.
2. Read the repository instructions and inspect `git status --short` before changing files.
3. Treat the repository root containing `install-skills.sh` and `skills/` as the destination project. Do not import into another repository unless the user explicitly names it.
4. Preserve unrelated user changes. Stop if the destination skill directory already exists; do not merge or overwrite it automatically.

## Preview the import

Resolve `SKILL_DIR` as the directory containing this `SKILL.md`, then run:

```bash
python3 "$SKILL_DIR/scripts/import_global_skill.py" <skill-name> --dry-run
```

The script searches, in order, the configured `CODEX_HOME` skill directory when present, `~/.codex/skills`, `~/.agents/skills`, and `~/.claude/skills`. It deduplicates paths that resolve to the same source and rejects sources that resolve inside this project's global or project-only skill directories.

If distinct global sources share the same name, inspect the reported paths and use the exact intended one:

```bash
python3 "$SKILL_DIR/scripts/import_global_skill.py" <skill-name> \
  --source /absolute/path/to/the/skill \
  --dry-run
```

Ask the user to choose only when repository context does not establish the intended source.

## Import and adapt

1. Re-run the preview command without `--dry-run`.
2. Use `--destination-name <new-name>` only when the user asks to rename or fork the skill. Use lowercase letters, digits, and hyphens.
3. Inspect every imported file before adapting it. Remove or replace machine-specific paths, credentials, private endpoints, organization-only assumptions, and unsupported tool dependencies. Never copy secret files into the repository.
4. Make the imported skill genuinely project-owned:
   - Keep `SKILL.md` frontmatter limited to `name` and `description`.
   - Ensure the folder name and frontmatter `name` match.
   - Describe this repository's workflow only where it materially changes how the skill operates.
   - Keep reusable scripts relative to the imported skill directory; do not assume a global installation path.
5. Ensure `agents/codex.yaml` accurately reflects the final `SKILL.md`. This repository requires `agents/codex.yaml` and forbids `agents/openai.yaml`. The import script renames a lone `openai.yaml` and creates minimal metadata when neither file exists; improve generic metadata when needed.
6. Do not run `install-skills.sh` unless the user also asks to install or refresh global links.

## Validate

Run the validator bundled with the available `skill-creator` skill. Resolve `SKILL_CREATOR_DIR` from that skill's `SKILL.md` location rather than assuming a user-specific path:

```bash
python3 "$SKILL_CREATOR_DIR/scripts/quick_validate.py" \
  "<project-root>/skills/<skill-name>"
```

Also verify the repository-specific contract:

```bash
test -f "skills/<skill-name>/agents/codex.yaml"
test ! -e "skills/<skill-name>/agents/openai.yaml"
git diff --check
```

Run focused tests for any imported or adapted scripts. Report the source path, destination path, adaptations, and validation results. Do not commit or push unless the user explicitly asks.

## Script safety

`scripts/import_global_skill.py`:

- performs a read-only preview with `--dry-run`;
- refuses an existing destination;
- refuses project-managed global symlinks that point back into this repository;
- refuses symlinks inside the source so the imported copy cannot retain hidden external dependencies;
- stages the copy before atomically moving it into `skills/`;
- excludes transient `.git`, `.DS_Store`, `__pycache__`, and compiled Python files.

If the script refuses a source, inspect the reported reason. Do not bypass the guardrail by manually copying files unless the user understands and explicitly approves the exceptional dependency.
