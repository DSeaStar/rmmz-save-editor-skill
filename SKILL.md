# RPG Maker MZ/MV Save Editor

Edit RPG Maker MZ/MV game save files to modify gold, character stats, items, and more.

## Overview

This skill provides tools and knowledge for editing RPG Maker MZ/MV save files (`.rmmzsave` and `.rpgsave`). It handles the special encoding used by these games and provides a Python API for save modification.

## Features

- ✅ Decode/encode RPG Maker MZ/MV save files
- ✅ Modify gold amount
- ✅ Modify character stats (HP, MP, Level)
- ✅ Modify items and variables
- ✅ Batch operations
- ✅ Automatic backup creation
- ✅ Command-line interface
- ✅ Python API for scripting

## Installation

### Method 1: Using npx skills

```bash
npx skills add DSeaStar/rmmz-save-editor-skill
```

### Method 2: Direct Download

Clone the repository:
```bash
git clone https://github.com/DSeaStar/rmmz-save-editor.git
```

## Quick Start

### Command Line Usage

```bash
# List all save files and their gold amounts
python rmmz_save_editor.py --list

# Modify gold in save slot 1
python rmmz_save_editor.py save/file0.rmmzsave 999999

# Interactive mode
python rmmz_save_editor.py --interactive
```

### Python API

```python
from rmmz_save_editor import RMMZSaveEditor

editor = RMMZSaveEditor()

# Read gold amount
current_gold = editor.get_gold('save/file0.rmmzsave')
print(f"Current gold: {current_gold}")

# Modify gold
editor.set_gold('save/file0.rmmzsave', 999999)
print("Gold modified!")

# Read and modify save data
data = editor.read_save('save/file0.rmmzsave')
data['actors'][0]['_hp'] = 9999
editor.write_save('save/file0.rmmzsave', data)
```

## Save File Format

RPG Maker MZ/MV uses a special save format:

1. **Data Structure**: JSON format
2. **Compression**: zlib (pako) level 1
3. **Encoding**: Compressed binary data is UTF-8 encoded
   - Example: `0xED` → `0xC3 0xAD`
4. **File Extensions**: `.rmmzsave` (MZ) or `.rpgsave` (MV)

### Encoding/Decoding Process

```
Save File → UTF-8 Decode → zlib Decompress → JSON
JSON → zlib Compress (level 1) → UTF-8 Encode → Save File
```

## Editable Values

### Gold
```python
data['party']['_gold'] = 999999
```

### Character Stats
```python
# Character 1 (index 0)
data['actors'][0]['_hp'] = 9999      # HP
data['actors'][0]['_mp'] = 999       # MP
data['actors'][0]['_level'] = 99     # Level
data['actors'][0]['_exp'] = 9999999  # EXP
```

### Items
```python
# Item ID 1, quantity 99
data['party']['_items']['1'] = 99
```

### Variables
```python
# Variable 1 = 100
data['variables'][1] = 100
```

### Switches
```python
# Switch 1 = ON
data['switches'][1] = True
```

## Save File Mapping

| In-Game Slot | MZ Filename | MV Filename |
|--------------|-------------|-------------|
| Save 1 | `file0.rmmzsave` | `file0.rpgsave` |
| Save 2 | `file1.rmmzsave` | `file1.rpgsave` |
| Save 3 | `file2.rmmzsave` | `file2.rpgsave` |
| Global | `global.rmmzsave` | `global.rpgsave` |
| Config | `config.rmmzsave` | `config.rpgsave` |

## Important Notes

1. **Close the game** before editing saves to prevent memory cache from overwriting changes
2. **Steam Cloud Save**: If the game uses Steam cloud saves, disable cloud sync first
3. **Always backup**: The tool automatically creates `.backup` files
4. **Don't set values too high**: Extremely large numbers may cause game crashes
5. **Verify JSON format**: Ensure modified JSON is valid

## Troubleshooting

### Cannot decode save file
- Verify the file is a valid RPG Maker save
- Some games may use additional encryption

### Game cannot load modified save
- Restore from `.backup` file
- Ensure game was closed before editing
- Check if Steam cloud save overwrote local file

### Gold amount didn't change
- Verify you edited the correct save slot
- Ensure game was restarted after modification

## Examples

### Example 1: Modify All Saves

```python
from rmmz_save_editor import RMMZSaveEditor

editor = RMMZSaveEditor()

# Modify all save files
for i in range(3):
    save_path = f'save/file{i}.rmmzsave'
    if os.path.exists(save_path):
        editor.set_gold(save_path, 999999)
        print(f"Modified save {i+1}")
```

### Example 2: Max Out Character Stats

```python
data = editor.read_save('save/file0.rmmzsave')

# Max out first character
if len(data.get('actors', [])) > 0:
    data['actors'][0]['_hp'] = 9999
    data['actors'][0]['_mp'] = 999
    data['actors'][0]['_level'] = 99
    data['actors'][0]['_exp'] = 9999999
    
    # Max params if available
    if '_params' in data['actors'][0]:
        data['actors'][0]['_params'] = [9999, 999, 999, 999, 999, 999, 999, 999]

editor.write_save('save/file0.rmmzsave', data)
```

### Example 3: Batch Edit

```python
# Modify multiple values at once
data = editor.read_save('save/file0.rmmzsave')

# Set gold
data['party']['_gold'] = 999999

# Add items
if '_items' not in data['party']:
    data['party']['_items'] = {}
data['party']['_items']['1'] = 99  # Item ID 1 x99
data['party']['_items']['2'] = 99  # Item ID 2 x99

# Set variables
if len(data.get('variables', [])) < 10:
    data['variables'] = data.get('variables', []) + [0] * (10 - len(data.get('variables', [])))
data['variables'][1] = 100
data['variables'][2] = 200

editor.write_save('save/file0.rmmzsave', data)
```

## Technical Details

### Core Functions

```python
# Decode UTF-8 encoded binary data
def utf8_garbage_to_binary(data: bytes) -> bytes:
    result = bytearray()
    i = 0
    while i < len(data):
        b = data[i]
        if b == 0xc2 and i + 1 < len(data):
            next_b = data[i + 1]
            decoded = ((b & 0x1f) << 6) | (next_b & 0x3f)
            result.append(decoded)
            i += 2
        elif b == 0xc3 and i + 1 < len(data):
            next_b = data[i + 1]
            decoded = ((b & 0x1f) << 6) | (next_b & 0x3f)
            result.append(decoded)
            i += 2
        elif b >= 0x80:
            result.append(b)
            i += 1
        else:
            result.append(b)
            i += 1
    return bytes(result)

# Encode binary data to UTF-8 format
def binary_to_utf8_garbage(data: bytes) -> bytes:
    result = bytearray()
    for b in data:
        if b < 0x80:
            result.append(b)
        else:
            result.append(0xc0 | (b >> 6))
            result.append(0x80 | (b & 0x3f))
    return bytes(result)
```

## References

- RPG Maker MZ: https://www.rpgmakerweb.com/products/rpg-maker-mz
- RPG Maker MV: https://www.rpgmakerweb.com/products/rpg-maker-mv
- GitHub Repository: https://github.com/DSeaStar/rmmz-save-editor

## License

MIT License - See LICENSE file for details.

## Disclaimer

This tool is for educational purposes. Please respect game developers and use responsibly. Always backup your save files before modification.
