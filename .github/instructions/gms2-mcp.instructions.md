---
description: "Use when implementing, reviewing, or debugging non-trivial gameplay/system tasks in this GameMaker project. Prefer gathering project-wide context with mcp_gms2-mcp_export_project_data before making architecture or behavior changes."
---

# GMS2 MCP Context Workflow

Use this workflow for game logic changes, bug fixes, balancing work, and architecture-level edits.

## Primary Rule

- For non-trivial gameplay/system tasks, default to calling `mcp_gms2-mcp_export_project_data` first to capture project-wide context.
- Treat the export as a map of current assets, scripts, and object relationships before proposing or editing code.

## When To Use Full Export First

- Multi-file changes
- Behavior changes that touch enemy, tower, wave, HP economy, or UI flow
- Refactors where parent/child object structure matters
- Code review and root-cause debugging

## Then Narrow With Targeted MCP Tools

- Use `mcp_gms2-mcp_get_object_info` for object events and inheritance details
- Use `mcp_gms2-mcp_get_gml_file_content` for exact code inspection
- Use `mcp_gms2-mcp_list_project_assets` to confirm asset names and categories
- Use room/sprite tools only when room setup or visual linkage is relevant

## Jam-Speed Guidance

- Prefer smallest safe change that preserves the Equivalent Exchange loop
- Reuse existing parent behaviors instead of introducing large new systems
- Keep balance knobs centralized in constants/macros for fast tuning

## Output Expectations

- State that project data was exported when it was used
- Mention key assets/scripts that informed the change
- If export is unavailable, explicitly fall back to local file inspection and note the risk of incomplete context
