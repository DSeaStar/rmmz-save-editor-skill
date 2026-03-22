# RPG Maker MZ/MV Save Editor Skill

An agent skill for editing RPG Maker MZ/MV game save files.

## Installation

```bash
npx skills add DSeaStar/rmmz-save-editor-skill
```

## What is this?

This skill provides tools and knowledge for editing RPG Maker MZ/MV save files, including:

- Decoding/encoding special save file format
- Modifying gold, stats, items, and variables
- Python API and command-line interface
- Automatic backup creation

## Main Repository

The actual tool is maintained at:
https://github.com/DSeaStar/rmmz-save-editor

## Usage

After installing this skill, your agent will be able to help you:

1. Decode RPG Maker save files
2. Modify game data (gold, stats, items)
3. Create custom modifications
4. Troubleshoot save file issues

## Quick Example

```python
from rmmz_save_editor import RMMZSaveEditor

editor = RMMZSaveEditor()
editor.set_gold('save/file0.rmmzsave', 999999)
```

## License

MIT
