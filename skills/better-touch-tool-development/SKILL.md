---
name: better-touch-tool-development
description: Advanced skill for developing, optimizing, and debugging Better Touch Tool presets, scripts, widgets, and floating menus. Includes preset analysis, icon optimization, security best practices, and real-world examples from GoldenChaos-BTT.
version: 2.0
updated: 2026-02-04
---

# Better Touch Tool Development Skill

This skill provides comprehensive resources for extending Better Touch Tool functionality using JavaScript, AppleScript, HTML/CSS, and advanced preset optimization techniques.

## 📚 Resources & Documentation

- **Official Docs**: [http://docs.folivora.ai](http://docs.folivora.ai)
- **Scripting Docs**: [http://docs.folivora.ai/docs/1100_scripting.html](http://docs.folivora.ai/docs/1100_scripting.html)
- **Community Forum**: [community.folivora.ai](https://community.folivora.ai)
- **GoldenChaos-BTT**: Premium preset example (community-maintained)

---

## 🛠️ Scripting Cheat Sheet

### JavaScript (Recommended)

BTT uses a modern JavaScript environment with async/await support.

#### Basic API Calls

```javascript
// Call a named trigger
await callBTT('trigger_named', { trigger_name: 'MyTrigger' });

// Update a widget (Touch Bar / Stream Deck)
await callBTT('update_touch_bar_widget', {
    uuid: 'WIDGET_UUID',
    text: 'New Text',
    background_color: '255,0,0,255'
});

// Get a variable
let myVar = await callBTT('get_string_variable', { variable_name: 'myVar' });

// Set a variable
await callBTT('set_string_variable', { variable_name: 'myVar', to: 'value' });

// Execute AppleScript from JS
let result = await callBTT('runAppleScript', { 
    script: 'tell application "Finder" to get name of every window' 
});

// Shell Script
let shellResult = await callBTT('runShellScript', { script: 'echo "hello"' });
```

#### Context Isolation

**Non-Isolated Context** (default):
```javascript
// Direct access to BTT globals
callBTT('trigger_named', {name: 'MyTrigger'});
get_string_variable('myVar');
set_string_variable('myVar', 'value');
```

**Isolated Context** (secure):
```javascript
// Must use window.bttAPI
window.bttAPI.callBTT('trigger_named', {name: 'MyTrigger'});
window.bttAPI.get_string_variable('myVar');
window.bttAPI.set_string_variable('myVar', 'value');
```

**When to use isolated context**:
- ✅ Scripts are self-contained
- ✅ No BTT global dependencies
- ✅ Enhanced security needed

**When to keep non-isolated**:
- ✅ Using BTT global functions extensively
- ✅ Legacy scripts
- ✅ Quick prototyping

### AppleScript (Legacy/Integrations)

```applescript
tell application "BetterTouchTool"
    trigger_named "MyTrigger"
    update_touch_bar_widget "UUID" text "New Text"
    get_string_variable "myVar"
    set_string_variable "myVar" to "value"
end tell
```

---

## 🎨 HTML Widgets & Floating Menus

### HTML Widget Template

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { 
            margin: 0; 
            padding: 10px; 
            background: transparent; 
            color: white; 
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display'; 
        }
        .btn { 
            background: rgba(255,255,255,0.2); 
            border-radius: 5px; 
            padding: 5px 10px; 
            cursor: pointer;
            transition: background 0.2s;
        }
        .btn:hover { background: rgba(255,255,255,0.4); }
    </style>
</head>
<body>
    <div class="btn" onclick="triggerAssignedActions(event.target)">
        Run Action
    </div>

    <script>
        // BTT injects this automatically
        function triggerAssignedActions(element) {
            window.webkit.messageHandlers.BTTTriggerAssignedActions.postMessage("trigger");
        }
        
        // Receive data from BTT scripts
        async function BTTInitialize() {
            // Initialization code
        }
    </script>
</body>
</html>
```

### Floating Menu JSON Format

```json
{
  "BTTMenuItems": [
    {
      "BTTMenuItemTitle": "Menu Item 1",
      "BTTMenuItemIcon": "base64_encoded_image_data",
      "BTTMenuItemAction": {
        "BTTPredefinedActionType": 5,
        "BTTPredefinedActionName": "Run AppleScript"
      }
    }
  ]
}
```

---

## 📦 Preset Structure & Optimization

### Preset File Format

BTT presets are `.bttpreset` JSON files packaged in `.bttpresetzip` archives.

**Structure**:
```
preset.bttpresetzip
├── Resources/
│   └── [UUID files] - AppleScript snippets, images
└── presetjson.bttpreset - Main JSON configuration
```

### JSON Schema Overview

```json
{
  "BTTPresetName": "My Preset",
  "BTTPresetUUID": "unique-uuid",
  "BTTPresetColor": "R, G, B, A",
  "BTTGeneralSettings": {
    "BTTHTTPServerPort": 12345,
    "BTTTouchBarVisible": true,
    // ... 100+ settings
  },
  "BTTPresetSnapAreas": [],
  "BTTPresetContent": [
    {
      "BTTAppName": "Global",
      "BTTTriggers": [
        {
          "BTTTriggerType": 0,
          "BTTTriggerClass": "BTTTriggerTypeKeyboardShortcut",
          "BTTTriggerName": "My Trigger",
          "BTTShortcutKeyCode": 18,
          "BTTShortcutModifierKeys": 1048576,
          "BTTPredefinedActionType": 551,
          "BTTIconData": "base64_png_data"
        }
      ]
    }
  ]
}
```

### Common Trigger Types

| Type | Description | Class |
|------|-------------|-------|
| 0 | Keyboard Shortcut | BTTTriggerTypeKeyboardShortcut |
| 108 | Trackpad Gesture | BTTTriggerTypeTouchpadGesture |
| 202 | Keyboard Shortcut (alternate) | BTTTriggerTypeKeyboardShortcut |
| 629 | Menu Bar Item | BTTTriggerTypeMenuBarItem |
| 630 | Control Strip Item | BTTTriggerTypeControlStripItem |
| 639 | Touch Bar Button | BTTTriggerTypeTouchBarButton |
| 643 | Named Trigger | BTTTriggerTypeOtherTriggers |

### Modifier Key Codes

| Modifier | Value |
|----------|-------|
| Cmd | 1048576 |
| Shift | 131072 |
| Option | 524288 |
| Control | 262144 |
| Cmd+Shift | 1179648 |
| Cmd+Option | 1572864 |

### macOS Key Codes

| Key | Code | Key | Code |
|-----|------|-----|------|
| 1 | 18 | 6 | 23 |
| 2 | 19 | 7 | 25 |
| 3 | 20 | 8 | 26 |
| 4 | 21 | 9 | 28 |
| 5 | 22 | 0 | 29 |

---

## 🔧 Preset Optimization Techniques

### 1. Naming Triggers

**Problem**: Unnamed triggers make debugging impossible.

**Solution**: Use descriptive names with prefixes:
```javascript
// Good naming convention
"CM_Paste_Item_1"  // Clipboard Manager
"WM_Snap_Left"     // Window Manager
"AI_Process_Text"  // AI Integration
"MC_Play_Pause"    // Media Control
```

**jq Script to Name Triggers**:
```bash
jq '.BTTPresetContent |= map(
  if .BTTAppName == "My App" then
    .BTTTriggers |= map(
      .BTTTriggerName = "PREFIX_\(.BTTOrder + 1)"
    )
  else . end
)' preset.bttpreset > preset-named.bttpreset
```

### 2. Icon Optimization

**Problem**: Embedded base64 icons can bloat preset files (30-40% of total size).

**Analysis**:
```bash
# Count icons
jq '[.BTTPresetContent[].BTTTriggers[]? | select(.BTTIconData != null)] | length' preset.bttpreset

# Total icon size
jq '[.BTTPresetContent[].BTTTriggers[]? | select(.BTTIconData != null) | .BTTIconData | length] | add' preset.bttpreset

# Largest icons
jq -r '[.BTTPresetContent[].BTTTriggers[]? | select(.BTTIconData != null) | {size: (.BTTIconData | length), name: .BTTTriggerName}] | sort_by(-.size) | .[0:5] | .[] | "\(.size) - \(.name)"' preset.bttpreset
```

**Optimization Strategy**:
```bash
# Extract icon
echo "$BASE64_DATA" | base64 -d > icon.png

# Resize (Touch Bar max 256×256, Menu Bar max 512×512)
convert icon.png -resize 256x256\> icon-resized.png

# Compress (lossy)
pngquant --quality=60-80 icon-resized.png -o icon-compressed.png

# Optimize (lossless)
optipng -o2 icon-compressed.png

# Re-encode
base64 -i icon-compressed.png
```

**Expected Savings**:
- Conservative: 10-15% reduction
- Aggressive: 20-30% reduction

### 3. HTTP Server Security

**Default Port**: 12345 (well-known, security risk)

**Recommendation**: Change to non-standard port:
```json
{
  "BTTGeneralSettings": {
    "BTTHTTPServerPort": 54321
  }
}
```

**Update with jq**:
```bash
jq '.BTTGeneralSettings.BTTHTTPServerPort = 54321' preset.bttpreset > preset-secure.bttpreset
```

### 4. Performance Settings

**Recommended Optimizations**:
```json
{
  "BTTGeneralSettings": {
    "BTTWindowSnappingHighPerformanceMode": true,
    "BSTMemorySaver": true,
    "BTTNoShortcutDelay": true,
    "BTTTouchBarAnimateGroups": false,
    "BTTEnableUsageLogging": false
  }
}
```

---

## 🔍 Preset Analysis Tools

### Extract Preset Statistics

```bash
#!/bin/bash
PRESET="preset.bttpreset"

echo "Preset Name: $(jq -r '.BTTPresetName' $PRESET)"
echo "UUID: $(jq -r '.BTTPresetUUID' $PRESET)"
echo "Configurations: $(jq '.BTTPresetContent | length' $PRESET)"
echo "Total Triggers: $(jq '[.BTTPresetContent[].BTTTriggers[] | length] | add' $PRESET)"
echo "Snap Areas: $(jq '.BTTPresetSnapAreas | length' $PRESET)"

# Trigger breakdown
jq -r '.BTTPresetContent[] | "\(.BTTAppName): \(.BTTTriggers | length) triggers"' $PRESET | sort
```

### Find Triggers by Type

```bash
# Find all keyboard shortcuts
jq -r '.BTTPresetContent[].BTTTriggers[] | select(.BTTTriggerType == 0) | .BTTTriggerName' preset.bttpreset

# Find named triggers
jq -r '.BTTPresetContent[].BTTTriggers[] | select(.BTTTriggerType == 643) | .BTTTriggerName' preset.bttpreset

# Find Touch Bar buttons
jq -r '.BTTPresetContent[].BTTTriggers[] | select(.BTTTriggerType == 639) | .BTTTriggerName' preset.bttpreset
```

### Validate Preset Integrity

```bash
# Check JSON validity
jq empty preset.bttpreset && echo "✅ Valid JSON" || echo "❌ Invalid JSON"

# Check for duplicate UUIDs
jq '[.BTTPresetContent[].BTTTriggers[].BTTUUID] | group_by(.) | map(select(length > 1))' preset.bttpreset

# Check for unnamed triggers
jq '[.BTTPresetContent[].BTTTriggers[] | select(.BTTTriggerName == null or .BTTTriggerName == "")] | length' preset.bttpreset
```

---

## 🧪 Testing & Debugging

### Enable Debug Logging

```javascript
// In your BTT scripts
console.log("Debug message");  // Visible in BTT Scripting Runner

// For widgets, use Web Inspector
// BTT → Preferences → Advanced → Enable Web Inspector
```

### Test Triggers Programmatically

```javascript
// Test a named trigger
await callBTT('trigger_named', { trigger_name: 'TestTrigger' });

// Test with delay
await new Promise(resolve => setTimeout(resolve, 1000));
await callBTT('trigger_named', { trigger_name: 'NextTrigger' });
```

### Error Handling

```javascript
try {
    const result = await callBTT('get_string_variable', { variable_name: 'myVar' });
    if (!result) {
        console.log("Variable not set");
    }
} catch (error) {
    console.error("BTT call failed:", error);
}
```

---

## 💡 Real-World Examples

### Example 1: Clipboard Manager (Cmd+1-9)

```javascript
// Trigger configuration
{
  "BTTTriggerName": "CM_Paste_Item_1",
  "BTTTriggerType": 0,
  "BTTShortcutKeyCode": 18,  // Key "1"
  "BTTShortcutModifierKeys": 1048576,  // Cmd
  "BTTPredefinedActionType": 123,  // Paste from clipboard history
  "BTTClipboardHistoryIndex": 0
}
```

### Example 2: AI HUD Integration

```javascript
// Named trigger to show AI menu
{
  "BTTTriggerName": "ShowAIHud",
  "BTTTriggerType": 643,
  "BTTActionsToExecute": [
    {
      "BTTPredefinedActionType": 551,  // Show JSON Menu
      "BTTAdditionalActionData": {
        "BTTActionShowWithSimpleJSONFormatScriptSettings": {
          "BTTScriptType": 3,  // External file
          "BTTScriptExternalPath": "/path/to/menu-config.json",
          "BTTJavaScriptUseIsolatedContext": false
        }
      }
    }
  ]
}
```

### Example 3: Dynamic Touch Bar Widget

```javascript
// Update widget with system info
async function updateSystemWidget() {
    const cpuUsage = await callBTT('runShellScript', {
        script: "top -l 1 | grep 'CPU usage' | awk '{print $3}'"
    });
    
    await callBTT('update_touch_bar_widget', {
        uuid: 'WIDGET_UUID',
        text: `CPU: ${cpuUsage}`,
        background_color: cpuUsage > 80 ? '255,0,0,255' : '0,255,0,255'
    });
}

// Run every 5 seconds
setInterval(updateSystemWidget, 5000);
```

---

## 🚀 Workflow Best Practices

### Development Workflow

1. **Draft**: Write scripts in VS Code with syntax highlighting
2. **Test**: Create a test trigger in BTT
3. **Debug**: Use `console.log` and BTT Scripting Runner
4. **Optimize**: Minimize API calls, cache results
5. **Deploy**: Copy to BTT configuration
6. **Backup**: Export preset regularly

### Preset Management

1. **Version Control**: Keep preset backups with dates
2. **Naming Convention**: Use consistent trigger naming
3. **Documentation**: Comment complex triggers
4. **Modular Design**: Group related triggers by app
5. **Testing**: Test after every major change

### Performance Tips

- ✅ Minimize `callBTT` calls in loops
- ✅ Cache frequently accessed variables
- ✅ Use `async/await` properly
- ✅ Disable animations for performance
- ✅ Optimize icon sizes
- ❌ Avoid synchronous blocking calls
- ❌ Don't embed huge images

---

## 📊 Common Preset Patterns

### GoldenChaos-BTT Pattern

**Structure**:
- Home Strip (base Touch Bar)
- Specialized strips (Media, iTunes, Spotify)
- Menu Bar integration
- Dock badges
- Window snapping
- Clipboard manager

**Key Features**:
- Conditional visibility
- Dynamic widgets
- Extensive media controls
- Modal interfaces

### Minimalist Pattern

**Structure**:
- Essential shortcuts only
- Clean Touch Bar
- No animations
- Fast performance

### Power User Pattern

**Structure**:
- 200+ triggers
- App-specific configurations
- Custom gestures
- Advanced automation

---

## 🔐 Security Best Practices

1. **Change Default HTTP Port**: Don't use 12345
2. **Use Context Isolation**: When possible
3. **Validate External Input**: Sanitize data from APIs
4. **Limit Script Permissions**: Don't run as root
5. **Review Third-Party Presets**: Check for malicious code
6. **Keep BTT Updated**: Security patches

---

## 📚 Additional Resources

### Tools
- **jq**: JSON processor for preset manipulation
- **pngquant**: Icon compression
- **optipng**: Lossless PNG optimization
- **ImageMagick**: Image resizing

### Community Presets
- **GoldenChaos-BTT**: Premium Touch Bar preset
- **AquaTouch**: macOS-style Touch Bar
- **MTMR**: My TouchBar My Rules (alternative)

### Debugging
- **BTT Scripting Runner**: Built-in script tester
- **Web Inspector**: For HTML widgets
- **Console.app**: System logs

---

## 🎓 Advanced Topics

### Custom Floating Menus

Create context-aware menus that adapt to current application:

```javascript
async function generateContextMenu() {
    const frontApp = await callBTT('runAppleScript', {
        script: 'tell application "System Events" to get name of first process whose frontmost is true'
    });
    
    const menuItems = {
        "Safari": [
            {"title": "New Tab", "action": "cmd+t"},
            {"title": "Close Tab", "action": "cmd+w"}
        ],
        "Finder": [
            {"title": "New Folder", "action": "cmd+shift+n"},
            {"title": "Get Info", "action": "cmd+i"}
        ]
    };
    
    return JSON.stringify({
        "BTTMenuItems": menuItems[frontApp] || []
    });
}
```

### Widget Communication

Widgets can communicate with each other via variables:

```javascript
// Widget 1: Set data
await callBTT('set_string_variable', {
    variable_name: 'shared_data',
    to: JSON.stringify({count: 42})
});

// Widget 2: Read data
const data = await callBTT('get_string_variable', {
    variable_name: 'shared_data'
});
const parsed = JSON.parse(data);
```

---

## 📝 Checklists

### Before Releasing a Preset

- [ ] All triggers have descriptive names
- [ ] Icons optimized (< 100KB each)
- [ ] HTTP port changed from default
- [ ] No hardcoded file paths
- [ ] Tested on clean BTT install
- [ ] Documentation included
- [ ] Version number set
- [ ] Backup created

### Debugging Checklist

- [ ] Check BTT Scripting Runner for errors
- [ ] Verify trigger UUIDs are unique
- [ ] Test with BTT in verbose mode
- [ ] Check Console.app for crashes
- [ ] Validate JSON structure
- [ ] Test on different macOS versions

---

*Better Touch Tool Development Skill v2.0*  
*Updated: 2026-02-04*  
*Includes insights from GoldenChaos-BTT 3.563 analysis*
