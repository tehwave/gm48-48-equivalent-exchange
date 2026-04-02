---
description: "Use when writing or editing GML animation, VFX, phase/seed, or timing logic. Prevent malformed-variable bugs by avoiding arithmetic with instance id."
applyTo: "**/*.gml"
---

# GML Instance ID Safety

- Never use instance id directly in arithmetic expressions, mod operations, or frame-seed formulas.
- Use instance id only for identity checks and instance arguments (for example `instance_exists(target_id)` or `enemy_take_damage(target_id, damage, source_id)`).
- For per-instance animation phase offsets, use stable numeric values such as position-derived seeds (for example `floor((x * 0.13) + (y * 0.17))`).
- If a numeric seed must persist independently of position, initialize a dedicated numeric variable in Create and use that variable for math.
- When changing VFX frame progression, verify no expressions mix instance references with numeric operators.
