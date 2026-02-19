---
name: pdf
description: Generate and manipulate PDF documents programmatically. Create reports, merge PDFs, extract text/images, add watermarks, fill forms. Use when working with PDF creation, conversion, or manipulation tasks.
license: MIT
metadata:
  author: custom
  version: "1.0.0"
---

# PDF - PDF Document Processing

**Create, manipulate, and extract from PDFs.**

## When to Use

**Use for:**
- Generating PDF reports
- Merging/splitting PDFs
- Extracting text and images
- Converting documents to PDF
- Adding watermarks

**Triggers:**
- "Create a PDF"
- "Convert to PDF"
- "Extract PDF content"
- "Merge PDFs"

## Core Capabilities

### 1. PDF Generation
```python
from reportlab.pdfgen import canvas

c = canvas.Canvas("report.pdf")
c.drawString(100, 750, "Hello PDF")
c.save()
```

### 2. PDF Manipulation
```python
from PyPDF2 import PdfReader, PdfWriter

# Merge PDFs
writer = PdfWriter()
writer.append("file1.pdf")
writer.append("file2.pdf")
writer.write("merged.pdf")
```

### 3. Text Extraction
```python
from PyPDF2 import PdfReader

reader = PdfReader("document.pdf")
text = reader.pages[0].extract_text()
```

## Best Practices

### ✅ DO
- Compress images before embedding
- Use vector graphics when possible
- Set proper PDF metadata
- Handle encryption properly

### ❌ DON'T
- Embed uncompressed images
- Create overly complex layouts
- Forget accessibility features

## Integration

Works with:
- docx (convert Word → PDF)
- ocr (extract text from scanned PDFs)
- pptx (convert PowerPoint → PDF)

## Examples

```python
# Installation
pip install reportlab PyPDF2

# Generate PDF
from reportlab.pdfgen import canvas
c = canvas.Canvas("output.pdf")
c.drawString(100, 750, "My PDF Document")
c.save()

# Extract text
from PyPDF2 import PdfReader
reader = PdfReader("input.pdf")
print(reader.pages[0].extract_text())
```

---

**PDF power at your fingertips!** 📕
