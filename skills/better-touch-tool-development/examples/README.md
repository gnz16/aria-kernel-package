# BTT Development Examples

This directory contains example scripts and configurations for Better Touch Tool development and optimization.

## 🛠️ Optimization Tools

These shell scripts help maintain and optimize large BTT presets.

### `optimize-btt-preset.sh`
**Purpose**: General optimization for BTT preset JSON files.
- Names unnamed triggers (useful for debugging)
- Changes HTTP server ports to avoid defaults
- Analyzes file structure

**Usage**:
```bash
./optimize-btt-preset.sh
```

### `optimize-icons.sh`
**Purpose**: Reduces preset file size by compressing embedded icons.
- Extracts unique icons from the preset
- Compresses them using `pngquant` and `optipng`
- Re-encodes them back into the preset
- Can reduce preset size by 30-50%

**Usage**:
```bash
# Requires pngquant, optipng, imagemagick
brew install pngquant optipng imagemagick
./optimize-icons.sh
```

### `test-ai-hud-isolation.sh`
**Purpose**: Analyzes JavaScript files to check if they are compatible with BTT's "Isolated Context" mode.
- Scans for usage of BTT global functions (e.g., `callBTT`, `get_string_variable`)
- Validates JSON config structure
- Checks JS syntax
- Recommends whether to enable isolation or not

**Usage**:
```bash
./test-ai-hud-isolation.sh
```

## 📂 Configuration Examples

- **`floating-menu-setup.json`**: Example configuration for a custom floating menu.
- **`hello-world-widget.html`**: Basic template for an HTML-based BTT widget.
- **`volume-control.js`**: Example script for controlling system volume via BTT.
