---
name: docx
description: Create and manipulate Microsoft Word documents (.docx) programmatically. Generate reports, proposals, documentation with rich formatting, tables, images. Use when automating document creation or converting content to Word format.
license: MIT
metadata:
  author: custom
  version: "1.0.0"
---

# DOCX - Word Document Creation

**Programmatically create professional Word documents.**

## When to Use

**Use for:**
- Generating reports and proposals
- Creating documentation from templates
- Converting markdown/HTML to Word
- Automating document workflows

**Triggers:**
- "Create a Word document"
- "Generate DOCX report"
- "Convert to Word format"

## Core Capabilities

### 1. Document Generation
```python
from docx import Document

doc = Document()
doc.add_heading('Project Report', 0)
doc.add_paragraph('Executive Summary')
doc.save('report.docx')
```

### 2. Rich Formatting
- Headings, paragraphs, lists
- Bold, italic, underline
- Tables and charts
- Images and shapes

### 3. Template-Based
```python
doc = Document('template.docx')
doc.paragraphs[0].text = 'Custom Title'
doc.save('output.docx')
```

## Best Practices

### ✅ DO
- Use templates for consistency
- Validate data before insertion
- Handle images properly (compression)
- Save backups

### ❌ DON'T
- Generate large docs (>100 pages) without optimization
- Forget to close file handles
- Hardcode content

## Integration

Works with:
- pdf (convert DOCX → PDF)
- brainstorming (document ideas)
- writing-plans (format plans)

## Examples

```python
# Installation
pip install python-docx

# Basic usage
from docx import Document
doc = Document()
doc.add_heading('My Document', 0)
doc.add_paragraph('Hello World')
doc.save('output.docx')
```

---

**Professional documents, programmatically!** 📄
