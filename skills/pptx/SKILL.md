---
name: pptx
description: Create and modify PowerPoint presentations (.pptx) programmatically. Generate slides with text, images, charts, tables. Automate presentation creation from data. Use when building presentations dynamically or converting content to slides.
license: MIT
metadata:
  author: custom
  version: "1.0.0"
---

# PPTX - PowerPoint Presentation Creation

**Build professional presentations programmatically.**

## When to Use

**Use for:**
- Generating presentations from data
- Creating slide decks automatically
- Converting reports to slides
- Bulk presentation creation

**Triggers:**
- "Create a PowerPoint"
- "Generate PPTX slides"
- "Build presentation from data"

## Core Capabilities

### 1. Slide Creation
```python
from pptx import Presentation

prs = Presentation()
slide = prs.slides.add_slide(prs.slide_layouts[0])
title = slide.shapes.title
title.text = "My Presentation"
prs.save('output.pptx')
```

### 2. Rich Content
- Text boxes and shapes
- Images and charts
- Tables and SmartArt
- Animations (basic)

### 3. Data Visualization
```python
from pptx.chart.data import CategoryChartData

chart_data = CategoryChartData()
chart_data.categories = ['Q1', 'Q2', 'Q3']
chart_data.add_series('Sales', (10, 20, 30))
```

## Best Practices

### ✅ DO
- Use templates for branding
- Keep slides concise
- Optimize image sizes
- Test on PowerPoint/Keynote

### ❌ DON'T
- Overcrowd slides
- Use low-quality images
- Hardcode data
- Forget accessibility

## Integration

Works with:
- pdf (convert PPTX → PDF)
- docx (consistent formatting)
- brainstorming (slide outlines)

## Examples

```python
# Installation
pip install python-pptx

# Basic usage
from pptx import Presentation

prs = Presentation()
slide = prs.slides.add_slide(prs.slide_layouts[0])
slide.shapes.title.text = "Hello PowerPoint"
prs.save('presentation.pptx')
```

---

**Presentations made easy!** 📊
