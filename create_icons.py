#!/usr/bin/env python3
"""Generate simple PNG icon files for the Beszel Agent Synology package."""

from PIL import Image, ImageDraw, ImageFont
import sys

def create_icon(size, filename):
    """Create a simple icon with the Beszel logo style."""
    # Create image with a nice blue background (Beszel brand color)
    img = Image.new('RGB', (size, size), color='#0066CC')
    draw = ImageDraw.Draw(img)

    # Calculate font size based on image size
    font_size = size // 4

    try:
        # Try to use a nice font if available
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", font_size)
    except:
        try:
            font = ImageFont.truetype("/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf", font_size)
        except:
            # Fallback to default font
            font = ImageFont.load_default()

    # Draw "B" in white (for Beszel)
    text = "B"

    # Get text bounding box for centering
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]

    position = ((size - text_width) // 2, (size - text_height) // 2 - font_size // 8)

    # Draw white text
    draw.text(position, text, fill='white', font=font)

    # Draw a circular border for polish
    border_width = max(2, size // 36)
    draw.ellipse(
        [border_width, border_width, size - border_width, size - border_width],
        outline='white',
        width=border_width
    )

    # Save the image
    img.save(filename, 'PNG')
    print(f"Created {filename}: {size}x{size} PNG")

if __name__ == '__main__':
    try:
        create_icon(72, 'icons/PACKAGE_ICON.PNG')
        create_icon(256, 'icons/PACKAGE_ICON_256.PNG')
        print("Icons created successfully!")
    except ImportError:
        print("ERROR: PIL/Pillow not available. Trying simpler approach...", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)
