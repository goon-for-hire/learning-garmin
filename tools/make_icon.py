"""Generate simple launcher icons for the learning projects (run: python3 tools/make_icon.py)."""
import sys
from PIL import Image, ImageDraw, ImageFont

def icon(path, letter, rgb, size=70):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse((2, 2, size - 3, size - 3), fill=rgb + (255,))
    try:
        font = ImageFont.truetype("DejaVuSans-Bold.ttf", int(size * 0.55))
    except OSError:
        font = ImageFont.load_default()
    d.text((size / 2, size / 2), letter, fill=(0, 0, 0, 255), font=font, anchor="mm")
    img.save(path)

if __name__ == "__main__":
    out, letter, hexcol = sys.argv[1], sys.argv[2], sys.argv[3]
    icon(out, letter, tuple(int(hexcol[i:i + 2], 16) for i in (0, 2, 4)))
