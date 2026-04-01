---
applyTo: "**/*.yy"
---

# GameMaker Project Files (.yy) — CRITICAL REQUIREMENTS

This file applies to all GameMaker project definition files (`.yy`).

⚠️ **THESE STEPS ARE EXTREMELY NECESSARY** — Assets will NOT appear in the editor unless completed.

## Creating New Assets Manually

When you manually create `.yy` files and event files (instead of using Stitch UI), you MUST complete ALL of the following steps or the asset will be invisible in GameMaker:

### Step 1: Create the Asset Files

Create the `.yy` file in the correct directory:
- Objects: `objects/object_name/object_name.yy`
- Sprites: `sprites/sprite_name/sprite_name.yy`
- Sounds: `sounds/sound_name/sound_name.yy`
- Scripts: `scripts/script_name/script_name.yy`

Create any event files (e.g., `Create_0.gml`, `Step_0.gml`, `Draw_0.gml`) in the same directory.

### Step 2: Register in the Project File (.yyp) — MANDATORY

**This is the most commonly forgotten step.** Without this, the asset will NOT appear in the editor.

1. Open `bootleg-gm48-2.yyp`
2. Find the `"resources":[` array
3. Add a new entry for your asset in **alphabetical order**:

```json
{"id":{"name":"asset_name","path":"objects/asset_name/asset_name.yy",},},
```

**Format rules:**
- Use the exact path where your `.yy` file is located
- Maintain alphabetical order within the `resources` array
- Include the trailing comma after the closing `},}`

**Example:** Adding a `gm48` object:

```json
"resources":[
  {"id":{"name":"despawner","path":"objects/despawner/despawner.yy",},},
  {"id":{"name":"gm48","path":"objects/gm48/gm48.yy",},},  // ← Add here, alphabetically
  {"id":{"name":"ground","path":"objects/ground/ground.yy",},},
  // ... rest of assets
],
```

Without this step, the asset files exist but GameMaker won't recognize them.

### Step 3: Register Events in the Object .yy File (Objects Only)

For new **object** `.yy` files, even if event files (e.g., `Create_0.gml`, `Step_0.gml`) exist on disk, they won't load unless registered in the object's `eventList` array.

Add entries to the `"eventList":[...]` array:

```json
"eventList":[
  {"$GMEvent":"v1","%Name":"","collisionObjectId":null,"eventNum":0,"eventType":0,"isDnD":false,"name":"","resourceType":"GMEvent","resourceVersion":"2.0",},
  {"$GMEvent":"v1","%Name":"","collisionObjectId":null,"eventNum":0,"eventType":4,"isDnD":false,"name":"","resourceType":"GMEvent","resourceVersion":"2.0",},
],
```

**Event type codes:**
| Code | Event Type |
|------|-----------|
| 0 | Create |
| 1 | Destroy |
| 2 | Alarm |
| 3 | Step |
| 4 | Collision (requires collisionObjectId) |
| 5 | Keyboard |
| 6 | Mouse |
| 7 | Other |
| 8 | Draw |
| 9 | KeyPress |
| 10 | KeyRelease |
| 11 | Gesture |
| 12 | Asynchronous |

**CRITICAL:** Every event entry in `eventList` must have ALL fields present, including `collisionObjectId` (set to `null` if not a collision event). Missing fields will cause events to not load in the IDE even if the `.gml` files exist.

### Step 4: Required `.yy` File Fields

**Every `.yy` file MUST include these fields at the start:**

```json
{
  "$GMObject":"",       // ← REQUIRED: Must be EMPTY STRING "", NOT "v1"
  "%Name":"object_name",
  "managed":true,       // ← REQUIRED: Must be boolean true
  // ... rest of fields
}
```

**Critical field values:**
- `"$GMObject":""` — Must be empty string, NOT `"v1"` or any other value
- `"parent"` — Must point to the **project file**, NOT a folder
  ```json
  "parent":{
    "name":"bootleg-gm48-2",
    "path":"bootleg-gm48-2.yyp",  // ← Point to project, not folders/Objects.yy
  },
  ```

**Field order matters.** Follow this structure (from existing objects):

```json
{
  "$GMObject":"",
  "%Name":"object_name",
  "eventList":[...],  // ← MUST come third, right after %Name
  "managed":true,
  "name":"object_name",
  "overriddenProperties":[],
  "parent":{
    "name":"bootleg-gm48-2",
    "path":"bootleg-gm48-2.yyp",
  },
  "parentObjectId":null,
  "persistent":false,
  "physicsAngularDamping":0.1,
  "physicsDensity":0.5,
  "physicsFriction":0.2,
  "physicsGroup":0,
  "physicsKinematic":false,
  "physicsLinearDamping":0.1,
  "physicsObject":false,
  "physicsRestitution":0.1,
  "physicsSensor":false,
  "physicsShape":1,
  "physicsShapePoints":[],
  "physicsStartAwake":true,
  "preCreationCode":"",
  "properties":[],
  "resourceType":"GMObject",
  "resourceVersion":"2.0",
  "solid":false,
  "spriteId":null,
  "spriteMaskId":null,
  "tags":[],
  "transparent":false,
  "visible":true,
}
```

### Step 5: Reload in GameMaker

After registering in `.yyp` and setting up event lists:

1. **Close** the project in GameMaker IDE
2. **Reopen** using **Stitch: Open in GameMaker** command
3. The asset should now appear in the Assets Browser

## CRITICAL: Copy Field Order Exactly from Working Objects

**Do NOT manually create the field order.** GameMaker has a strict field ordering requirement that isn't documented. If fields are in the wrong order, you'll get cryptic parsing errors like `Error: Field "eventList": expected.`

**Solution: Copy the entire structure from an existing, working object file:**

1. Open a working object file like `objects/obstacles/obstacles.yy`
2. Copy the entire JSON structure
3. Modify only the field VALUES, never reorder fields:
   - Change `"name":"obstacles"` → `"name":"your_object"`
   - Change `"%Name":"obstacles"` → `"%Name":"your_object"`
   - Adjust physics properties if needed
4. Keep every field in the exact same order

**Why this matters:** Even if the JSON is syntactically valid and logically makes sense, GameMaker's parser expects fields in a specific order. Reordering causes parser errors that point to the wrong field.

**Never do this:**
```json
// BAD: You moved collisionKind before eventList
{
  "$GMObject":"",
  "%Name":"gm48",
  "collisionKind":1,        // ← This comes AFTER eventList in working objects
  "creation_code":"",
  "eventList":[...],        // ← Should be here
}
```

**Always do this:**
```json
// GOOD: Fields in exact order from obstacles.yy
{
  "$GMObject":"",
  "%Name":"gm48",
  "eventList":[...],        // ← Right after %Name, always
  "managed":true,
  "name":"gm48",
  // ... rest in exact order
}
```

**Critical:** Do not add fields that don't exist in working objects. Do not remove fields that do exist. Copy the ENTIRE structure exactly, only changing values like names.

## Common Mistakes (Why Assets Don't Appear)

| Problem | Solution |
|---------|----------|
| Asset exists but not in Assets Browser | Register in `bootleg-gm48-2.yyp` resources array |
| Event files exist but don't load in IDE | Register event in object's `eventList` array |
| Object `.yy` file is invalid JSON | Add `"$GMObject":"v1"` and `"managed":true` |
| Parent path is wrong | Use `"path":"folders/Objects.yy"` NOT project `.yyp` |
| Asset loads then disappears | Check for duplicate entries in `.yyp` |
| Project fails to load: "Field already exists" | **CRITICAL:** Check for duplicate fields in `.yy` file. Each field name must appear only once. |

### Duplicate Field Error

If you see: `Cannot load project... Field 'fieldname' already exists in GMRecord. Field names must be unique.`

**Check your `.yy` file for duplicate field declarations.** When manually creating `.yy` files, it's easy to accidentally include the same field twice:

```json
// BAD: resourceVersion appears twice
{
  "resourceType":"GMObject",
  "resourceVersion":"2.0",      // ← First occurrence
  "preCreationCode":"",
  "creation_code":"",
  "tags":[],
  "resourceVersion":"2.0",      // ← DUPLICATE: Remove this
  "name":"gm48",                // ← DUPLICATE: Remove this
  "tags":[],                    // ← DUPLICATE: Remove this
  "resourceType":"GMObject",    // ← DUPLICATE: Remove this
}

// GOOD: Each field appears exactly once
{
  "resourceType":"GMObject",
  "resourceVersion":"2.0",
  "preCreationCode":"",
  "creation_code":"",
  "tags":[],
}
```

**Always validate that each field name appears only once in the entire `.yy` file.**

### Version Mismatch Error

If you see: `Cannot find function to change GMObject version from v1 to v0.`

**The `$GMObject` field must be an empty string `""`, NOT `"v1"`:**

```json
// BAD
{
  "$GMObject":"v1",  // ← WRONG: This causes version mismatch error
  // ...
}

// GOOD
{
  "$GMObject":"",    // ← CORRECT: Empty string
  // ...
}
```

### Parent Path Error

If the project fails to load with parent-related errors:

**The `parent` object must point to the project file, NOT a folder:**

```json
// BAD
{
  "parent":{
    "name":"Objects",
    "path":"folders/Objects.yy",  // ← WRONG: Points to a folder
  },
}

// GOOD
{
  "parent":{
    "name":"bootleg-gm48-2",
    "path":"bootleg-gm48-2.yyp",  // ← CORRECT: Points to project file
  },
}
```

### Field Order Error

If you see: `Error: Field "eventList": expected.`

**The field order in the `.yy` JSON is strict.** Fields must appear in a specific order. Most critically, `eventList` MUST appear immediately after `%Name`:

```json
// BAD: eventList is in wrong position
{
  "$GMObject":"",
  "%Name":"gm48",
  "collisionKind":1,      // ← WRONG: This comes before eventList
  "creation_code":"",
  "eventList":[...],      // ← Should be here, right after %Name
}

// GOOD: eventList in correct position
{
  "$GMObject":"",
  "%Name":"gm48",
  "eventList":[...],      // ← CORRECT: Third field, right after %Name
  "managed":true,
  "collisionKind":1,      // ← Now it's in the right place
  "creation_code":"",
}
```

**When manually creating `.yy` files, copy the field order exactly from an existing working object file.**

## Preferred: Use Stitch UI Instead

**Strongly prefer using Stitch's UI for creating assets:**

- Right-click a folder in the Stitch tree → "New Object"
- Drag sprites into the Stitch tree
- Stitch automatically handles ALL registration steps

Manual `.yy` creation should only be done when:
- Bulk importing from another project
- Setting up complex asset hierarchies
- Scripting asset generation

## Verification Checklist

Before assuming your asset is "done":

- [ ] `.yy` file exists in the correct directory
- [ ] Event files (e.g., `Create_0.gml`) exist alongside `.yy` file
- [ ] Asset is registered in `bootleg-gm48-2.yyp` `resources` array
- [ ] Object events are registered in object's `eventList` (if object)
- [ ] JSON is valid (no syntax errors)
- [ ] **Field order matches exactly with existing working objects** — Do NOT deviate
- [ ] Asset appears in GameMaker Assets Browser after reload
- [ ] Asset can be placed/used in rooms without errors

## When Things Go Wrong

If an asset still doesn't appear after completing all steps:

1. **Check Stitch logs** → Output panel → "Stitch" dropdown
2. **Validate JSON** → Use an online JSON validator on your `.yy` file
3. **Check for duplicates** → Search `.yyp` for duplicate asset names
4. **Restart Stitch** → Close VSCode, reopen project with Stitch
5. **Restart GameMaker** → Close IDE, reopen with "Stitch: Open in GameMaker"
6. **Check git status** → Ensure `.yyp` and `.yy` files are not locked/conflicted

## Common Runtime Errors After Manual Asset Creation

### "Variable [object].[asset_name] not set before reading it"

This means you're referencing an asset (sprite, sound, object) that doesn't exist or is named incorrectly.

**Solution:**
1. Check the exact name of the asset in the `sprites/`, `sounds/`, or `objects/` folder
2. Verify the asset is registered in `bootleg-gm48-2.yyp`
3. Use the exact folder name (e.g., `spr_player` not `sp_player_sprite`)

**Example error:**
```
Variable obj_gm48.sp_gm48_logo not set before reading it.
```

**Fix:** The sprite folder is named `spr_gm48`, not `sp_gm48_logo`. Use `spr_gm48` in your code.

