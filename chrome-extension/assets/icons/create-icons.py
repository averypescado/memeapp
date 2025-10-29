#!/usr/bin/env python3
from PIL import Image, ImageDraw, ImageFont

def create_icon(size, filename):
    # Create a gradient background
    img = Image.new('RGB', (size, size), color='#667eea')
    draw = ImageDraw.Draw(img)

    # Draw a simple "M" in the center
    try:
        # Try to use a default font
        font_size = int(size * 0.6)
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", font_size)
    except:
        # Fallback to default font
        font = ImageFont.load_default()

    # Draw text
    text = "M"
    # Get text bounding box for centering
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]

    position = ((size - text_width) // 2, (size - text_height) // 2 - bbox[1])
    draw.text(position, text, fill='white', font=font)

    # Add a subtle border
    draw.rectangle([(0, 0), (size-1, size-1)], outline='#764ba2', width=2)

    # Save the image
    img.save(filename, 'PNG')
    print(f"Created {filename}")

# Create icons in different sizes
create_icon(16, 'icon16.png')
create_icon(48, 'icon48.png')
create_icon(128, 'icon128.png')

print("All icons created successfully!")
