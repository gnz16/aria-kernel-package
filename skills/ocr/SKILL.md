---
name: ocr
description: Extract text from images and scanned documents using Optical Character Recognition (OCR). Process PDFs, photos, screenshots. Supports multiple languages. Use when digitizing paper documents or extracting text from images.
license: MIT
metadata:
  author: custom
  version: "1.0.0"
---

# OCR - Optical Character Recognition

**Extract text from images and scanned documents.**

## When to Use

**Use for:**
- Digitizing paper documents
- Extracting text from screenshots
- Processing scanned PDFs
- Reading text from photos
- Converting images to searchable text

**Triggers:**
- "Extract text from image"
- "OCR this document"
- "Read text from screenshot"
- "Digitize paper document"

## Core Capabilities

### 1. Text Extraction
```python
import pytesseract
from PIL import Image

text = pytesseract.image_to_string(Image.open('image.png'))
```

### 2. Multi-Language Support
```python
# Detect language
text = pytesseract.image_to_string(img, lang='eng+fra+spa')
```

### 3. PDF Processing
```python
from pdf2image import convert_from_path

pages = convert_from_path('scanned.pdf')
for page in pages:
    text = pytesseract.image_to_string(page)
```

### 4. Confidence Scores
```python
data = pytesseract.image_to_data(img, output_type='dict')
confidence = data['conf']
```

## Best Practices

### ✅ DO
- Preprocess images (contrast, denoise)
- Use high-resolution images
- Specify correct language
- Validate OCR output
- Save original images

### ❌ DON'T
- Process low-quality images
- Expect 100% accuracy
- Skip preprocessing
- Ignore confidence scores

## Integration

Works with:
- pdf (extract from scanned PDFs)
- docx (save extracted text)
- systematic-debugging (verify accuracy)

## Examples

```python
# Installation
# macOS: brew install tesseract
# pip install pytesseract pillow pdf2image

# Basic usage
import pytesseract
from PIL import Image

# From image
text = pytesseract.image_to_string(Image.open('scan.png'))
print(text)

# With language
text = pytesseract.image_to_string(img, lang='eng')

# Get detailed data
data = pytesseract.image_to_data(img, output_type='dict')
```

## Preprocessing Tips

```python
from PIL import Image, ImageEnhance

# Enhance image
img = Image.open('scan.png')
img = img.convert('L')  # Grayscale
enhancer = ImageEnhance.Contrast(img)
img = enhancer.enhance(2)  # Increase contrast

# Then OCR
text = pytesseract.image_to_string(img)
```

## Supported Languages

- English (eng)
- Hindi (hin)
- Spanish (spa)
- French (fra)
- German (deu)
- 100+ more

## Notes

- Requires Tesseract OCR engine installed
- Accuracy depends on image quality
- Works best with clear, high-contrast text
- Can process handwriting (with lower accuracy)

---

**Turn images into text!** 👁️
