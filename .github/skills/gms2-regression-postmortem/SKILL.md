---
name: gms2-regression-postmortem
description: 'Investigate GameMaker regressions with commit forensics and safe recovery. Use when UI or gameplay suddenly disappears, objects stop responding, events are missing, spriteId becomes null, or .yy/.yyp edits caused breakage. Includes root-cause timeline, blast-radius analysis, and minimal rollback/fix verification.'
argument-hint: 'Describe symptom, suspected commit window, and whether to only diagnose or also repair.'
user-invocable: true
---

# GMS2 Regression Postmortem

Use this skill to find why a behavior disappeared, identify the exact commit that introduced it, assess what else broke, and apply minimal safe fixes.

## When to Use
- Build menu or HUD panel vanished
- Bases, towers, enemies, or interactions stopped rendering/responding
- Suspected object `.yy` corruption (`eventList`, `spriteId`, field order)
- Unclear whether breakage came from one commit or a chain
- You need a concise postmortem with concrete evidence

## Inputs
- Symptom summary from user
- Suspected file(s) or commit(s), if known
- Permission mode: diagnose-only or diagnose-and-repair

## Procedure
1. Confirm symptom gate first.
- Find the exact runtime condition that controls visibility/behavior in GML.
- Verify if code path is skipped due to false state, missing instance, or early return.

2. Export project context for non-trivial regressions.
- Run `mcp_gms2-mcp_export_project_data`.
- Search export for target object, associated `.yy`, and event file links.
- Verify assets exist and object/resource registration is present.

3. Validate object integrity in `.yy`.
- Check `spriteId` is bound when rendering depends on sprite.
- Check `eventList` contains required events (Create/Step/Mouse/Draw as appropriate).
- Ensure field order and structure remain valid for GameMaker parser expectations.

4. Run commit forensics.
- Use `git blame` on the exact broken lines.
- Use `git show <commit>` for changed files and key hunks.
- Inspect adjacent commits (`git log` and `git show`) to detect partial fixes and remaining regressions.

5. Determine blast radius.
- List all files changed in the introducing commit.
- Flag high-risk files: `.yy`, `.yyp`, global-state scripts, GUI draw flow, input handlers.
- Correlate each changed file with observed symptom(s).

6. Repair minimally and safely.
- Restore only required values/registrations first (for example `spriteId`, missing `eventList` entries).
- Avoid broad rewrites and avoid reverting unrelated user changes.
- If temporary fallback visuals were added during triage, remove or retain explicitly.

7. Verify with objective checks.
- `get_errors` on edited files.
- Workspace search to ensure no stale temporary symbols remain.
- Confirm trigger condition now reachable (example: entering `build_mode` after base click).
- Ask user to reload project/IDE when `.yy` registration changed.

8. Report postmortem clearly.
- What broke
- Why it broke
- Introducing commit
- What was being worked on in that commit
- What else likely broke
- What was fixed now vs still pending

## Decision Branches
- If symptom is visual-only and object has valid events: prioritize sprite binding, alpha logic, depth/layer checks.
- If interaction vanished: prioritize missing Mouse/Step event registration and state transitions.
- If GUI panel vanished: verify gate conditions (`build_mode`, selected/base instance validity, game-state guards).
- If commit changed many systems: isolate first unblock fix, then audit neighbors by risk.

## Quality Criteria
- Root cause tied to exact lines and commit hash
- No speculative claims without evidence from file or git output
- Minimal patch surface
- No new diagnostics errors
- User can reproduce fix with a simple in-game action

## Completion Checklist
- [ ] Introducing commit identified
- [ ] Broken mechanism explained in one sentence
- [ ] Affected files listed with impact notes
- [ ] Minimal fix applied or proposed
- [ ] Verification evidence captured
- [ ] Remaining risks and next checks called out

## Example Prompts
- `/gms2-regression-postmortem Build panel disappeared after yesterday commits; find root cause and fix safely.`
- `/gms2-regression-postmortem Bases are invisible and not clickable; tell me the introducing commit and blast radius.`
- `/gms2-regression-postmortem Diagnose only: what broke in the latest wip chain and why?`
