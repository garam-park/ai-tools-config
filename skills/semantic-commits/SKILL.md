---
name: semantic-commits
description: Split uncommitted changes into multiple commits grouped by semantic unit, down to hunk level when one file mixes concerns. Use ONLY when the user explicitly invokes `/semantic-commits`, `$semantic-commits`, or 의미별로 커밋. Do not trigger on ordinary commit requests.
---

# Semantic Commits

Turn a mixed working tree into a series of commits that each carry exactly one meaning. Optimize for a history that reviews one concern at a time, not for the fewest commands.

## Platforms (Cross-Tool)

원본은 이 리포의 `skills/semantic-commits/`이며, `install-skills.sh`가 아래 도구 경로에 리포 작업 트리를 직접 가리키는 심볼릭 링크를 만든다. 어느 도구에서 호출되든 동작은 동일하다.

- **Claude Code**: `~/.claude/skills/semantic-commits/`
- **Codex / GitHub Copilot / OpenCode**: `~/.agents/skills/semantic-commits/`

`agents/codex.yaml`은 Codex가 사용하는 선택적 UI 메타데이터다. `$semantic-commits`는 Codex 전용 슬래시-달러 문법이라 다른 클라이언트에서는 동작하지 않는다. 다른 도구는 공통 동작을 정의한 `SKILL.md`만 사용한다.

## Triggers

**명시 호출에만 발동한다**: `/semantic-commits`, `$semantic-commits`, "의미별로 커밋", "커밋 의미 단위로 나눠줘"

자동 트리거는 없다. "커밋해줘", "이거 커밋해" 같은 일반 커밋 요청에는 이 스킬을 쓰지 않고 평소대로 처리한다. 변경이 여러 의미로 섞여 보여도 사용자가 부르지 않으면 끌어오지 않는다.

## Workflow

### 1. Inspect

Read the full working tree state before deciding anything:

```bash
git status --short
git diff              # unstaged
git diff --staged     # already staged
git status --porcelain --untracked-files=all
```

Read the actual diff content, not just file names — the grouping decision depends on what each hunk does. If nothing is uncommitted, report that plainly and stop; do not invent work.

If some changes are already staged, treat the staging area as a draft, not as a decision. The plan may restage differently; say so in the announcement.

### 2. Group

Group changes into semantic units. Typical units:

- 기능 추가 — one behavior a user or caller can observe
- 버그 수정 — one defect and its regression test
- 리팩터링 — behavior-preserving restructuring, kept apart from behavior changes
- 문서 — README, guides, comments-only changes
- 설정/빌드 — config, CI, dependency, tooling changes
- 정리 — formatting, renames, dead-code removal, kept apart from logic changes

Rules for grouping:

- Each commit must be coherent on its own: the tree at that commit should build and pass the checks the repo cares about.
- A fix and the test that proves it belong in the same commit.
- Mechanical changes (rename, reformat, generated files) go in their own commit, separate from judgment changes, so review can skim one and read the other.
- When commit B depends on commit A, order A first. Never produce an ordering where an earlier commit references something a later commit introduces.
- If a single file carries more than one meaning, plan a hunk-level split (see step 4).

### 3. Announce

Before touching the index, show the plan and stop for a beat:

```markdown
커밋 {n}개로 나눌게요.

1. `type(scope): summary` — {파일 또는 헝크}
2. `type(scope): summary` — {파일 또는 헝크}
...
{헝크 분리가 필요한 파일과 이유}
{계획에서 제외한 변경과 이유}
```

Keep it short — file/hunk list plus draft messages, not a diff replay. If the grouping was a close call (a hunk that could belong to either commit, a file with unclear intent), name that choice explicitly so the user can correct it.

### 4. Stage & commit

Start from a clean index so staging is deliberate: `git reset` unstages everything without touching the working tree. Never use `git reset --hard`, `git checkout -- <path>`, or `git stash` here — they destroy uncommitted work.

**Whole-file staging** — when every change in a file belongs to one commit:

```bash
git add path/to/file.ts path/to/other.ts
git commit -m "feat(scope): summary"
```

New files are staged the same way with `git add`.

**Hunk-level staging** — when one file mixes concerns. Interactive `git add -p` cannot be driven from an agent session, so split the patch by hand and stage it non-interactively:

```bash
git diff -- path/to/file.ts > /tmp/file.patch     # capture the whole file's diff
# copy the patch header (diff --git / index / --- / +++) plus only the
# @@ hunks for this commit into /tmp/part1.patch
git apply --cached --check /tmp/part1.patch       # verify before staging
git apply --cached /tmp/part1.patch               # stage just those hunks
git diff --staged                                 # confirm what is staged
git commit -m "fix(scope): summary"
```

Then re-run `git diff -- path/to/file.ts` for the remainder and repeat. Notes:

- Every hunk from one `git diff` applies against the same index content, so hunks can be staged in any order. Re-generate the diff after each commit rather than reusing a stale patch.
- Each hunk-only patch must keep the original file header lines; a bare `@@` block will not apply.
- When you split one `@@` hunk into smaller pieces, the line counts in its header no longer match — apply with `git apply --cached --recount` and let git recompute them.
- To split an untracked file's changes, first make it visible to `git diff` with `git add -N path/to/file`, then use the patch flow above.
- If `--check` fails, stop and re-derive the patch from a fresh `git diff`. Do not force it with `--3way` or `--reject`.

Use the repo's own verification (tests, lint, build) before a commit whose correctness depends on it — a commit that cannot stand alone defeats the point of splitting.

### 5. Verify

After the last commit:

```bash
git status --short              # remaining changes are only what was intentionally left
git log --oneline -{n}          # the new commits, in order
git show --stat <sha>           # per-commit contents
```

Confirm no change was lost: the sum of the new commits plus what remains uncommitted must equal what step 1 saw. Report the commit list, what each one contains, and anything left uncommitted with the reason.

## Commit Messages

Match the target repository, not a personal preference:

```bash
git log --oneline -15
```

Follow the format and language that history shows — prefix style, scope usage, Korean or English, capitalization, trailing punctuation. If the repo has an explicit convention document (`CONTRIBUTING.md`, `AGENTS.md`, `CLAUDE.md`), that outranks what `git log` suggests.

With no discernible convention, default to Conventional Commits in English: `type(scope): summary`, imperative mood, lowercase summary, no trailing period. Use `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `build`, `ci`.

The subject states what changed; add a body only when the *why* is not obvious from the diff.

## Rules

- 변경 전체가 하나의 의미면 억지로 나누지 않는다. 커밋 1개로 처리하고 그 이유를 한 줄로 말한다.
- 이미 만들어진 커밋은 건드리지 않는다. `git rebase`, `git commit --amend`, `git reset --soft HEAD~` 등으로 기존 이력을 다시 쓰지 않는다. 이 스킬은 아직 커밋되지 않은 변경만 다룬다.
- push는 사용자가 명시적으로 요청할 때만 한다. 커밋까지 하고 멈춘다.
- 커밋 메시지에 `Co-Authored-By: Claude`, `Generated with Claude Code` 같은 AI 관련 트레일러·서명·푸터를 넣지 않는다.
- 요청 범위 밖의 변경(무관한 untracked 파일, 임시 파일, 로컬 설정)은 커밋에 포함하지 않는다. 포함 여부가 애매하면 커밋하지 말고 사용자에게 묻는다.
- 커밋을 나누려고 코드를 고치지 않는다. 분리가 안 되는 변경은 한 커밋으로 묶고 그 사실을 밝힌다.
- 작업 트리를 잃는 명령(`reset --hard`, `checkout --`, `stash`, `clean`)은 사용자가 명시적으로 요청하지 않는 한 쓰지 않는다.
