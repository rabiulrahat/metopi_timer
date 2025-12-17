#!/usr/bin/env python3
"""Create a simple timer icon PNG."""
from PIL import Image, ImageDraw, ImageFont
import os

# Create a simple icon: blue background with white "T" (timer)
size = 256
img = Image.new('RGB', (size, size), color='#2563eb')
draw = ImageDraw.Draw(img)

# Draw a simple circle/timer shape
margin = 20
draw.ellipse([margin, margin, size-margin, size-margin], outline='white', width=4)

# Try to draw text, fallback to simple shape if font unavailable
try:
    font = ImageFont.load_default()
    draw.text((size//2 - 20, size//2 - 20), "T", fill='white', font=font)
except:
    # Fallback: draw a simple rectangle
    draw.rectangle([size//3, size//3, 2*size//3, 2*size//3], outline='white', width=3)

# Ensure assets directory exists
os.makedirs('assets', exist_ok=True)

# Save the icon
img.save('assets/icon.png')
print("Created assets/icon.png")
