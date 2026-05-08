"""Generate the app launcher icon for Reasoned.

Creates two PNGs:
  - assets/icon/icon.png            : full square icon (used for iOS / legacy Android)
  - assets/icon/icon_foreground.png : transparent foreground glyph (Android adaptive)

Run:
    python tool/make_icon.py
"""

from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "assets" / "icon"
OUT_DIR.mkdir(parents=True, exist_ok=True)

SIZE = 1024
PRIMARY = (103, 80, 164, 255)        # M3 purple seed
PRIMARY_LIGHT = (155, 130, 220, 255)  # lighter purple
ACCENT = (0, 200, 165, 255)          # teal/green for the check
WHITE = (255, 255, 255, 255)


def rounded_square(size, radius, color):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=color)
    return img


def gradient_square(size, radius, top_color, bottom_color):
    """Linear vertical gradient between top_color and bottom_color, masked to a rounded square."""
    grad = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    for y in range(size):
        t = y / (size - 1)
        r = int(top_color[0] * (1 - t) + bottom_color[0] * t)
        g = int(top_color[1] * (1 - t) + bottom_color[1] * t)
        b = int(top_color[2] * (1 - t) + bottom_color[2] * t)
        for x in range(size):
            grad.putpixel((x, y), (r, g, b, 255))
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=255)
    out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    out.paste(grad, (0, 0), mask)
    return out


def speech_bubble(width, height, color, tail="left"):
    img = Image.new("RGBA", (width, height + height // 4), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle((0, 0, width, height), radius=height // 4, fill=color)
    # tail
    if tail == "left":
        cx = width // 5
        d.polygon(
            [
                (cx, height - 2),
                (cx + height // 5, height + height // 4),
                (cx + height // 3, height - 2),
            ],
            fill=color,
        )
    else:
        cx = width - width // 5
        d.polygon(
            [
                (cx, height - 2),
                (cx - height // 5, height + height // 4),
                (cx - height // 3, height - 2),
            ],
            fill=color,
        )
    return img


def make_glyph(size):
    """White glyph: two overlapping speech bubbles + a teal check mark."""
    g = Image.new("RGBA", (size, size), (0, 0, 0, 0))

    bubble_back_w, bubble_back_h = int(size * 0.62), int(size * 0.46)
    bubble_front_w, bubble_front_h = int(size * 0.62), int(size * 0.46)

    back = speech_bubble(bubble_back_w, bubble_back_h, (255, 255, 255, 230), tail="right")
    front = speech_bubble(bubble_front_w, bubble_front_h, WHITE, tail="left")

    # placement
    bx = int(size * 0.10)
    by = int(size * 0.18)
    g.paste(back, (bx, by), back)

    fx = int(size * 0.28)
    fy = int(size * 0.36)
    g.paste(front, (fx, fy), front)

    # check mark on the front bubble
    d = ImageDraw.Draw(g)
    cx0, cy0 = fx + int(bubble_front_w * 0.20), fy + int(bubble_front_h * 0.55)
    cx1, cy1 = fx + int(bubble_front_w * 0.42), fy + int(bubble_front_h * 0.78)
    cx2, cy2 = fx + int(bubble_front_w * 0.78), fy + int(bubble_front_h * 0.28)
    width = max(8, size // 32)
    d.line([(cx0, cy0), (cx1, cy1)], fill=ACCENT, width=width, joint="curve")
    d.line([(cx1, cy1), (cx2, cy2)], fill=ACCENT, width=width, joint="curve")
    return g


def make_full_icon(size=SIZE):
    bg = gradient_square(size, radius=size // 5, top_color=PRIMARY_LIGHT, bottom_color=PRIMARY)

    # subtle glow behind glyph
    glow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    glow_d = ImageDraw.Draw(glow)
    glow_d.ellipse(
        (size // 5, size // 5, size - size // 5, size - size // 5),
        fill=(255, 255, 255, 40),
    )
    glow = glow.filter(ImageFilter.GaussianBlur(radius=size // 20))
    bg.alpha_composite(glow)

    glyph = make_glyph(size)
    bg.alpha_composite(glyph)
    return bg


def make_foreground(size=SIZE):
    """For Android adaptive icons: transparent background, glyph kept inside the safe zone."""
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    glyph = make_glyph(size).resize((int(size * 0.66), int(size * 0.66)), Image.LANCZOS)
    offset = (size - glyph.size[0]) // 2
    canvas.alpha_composite(glyph, dest=(offset, offset))
    return canvas


if __name__ == "__main__":
    full = make_full_icon()
    full.save(OUT_DIR / "icon.png")
    fg = make_foreground()
    fg.save(OUT_DIR / "icon_foreground.png")
    print(f"Wrote {OUT_DIR / 'icon.png'}")
    print(f"Wrote {OUT_DIR / 'icon_foreground.png'}")
