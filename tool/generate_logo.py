"""Generate square Plime logo 512x512 without stretching."""
from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw

SIZE = 512
OUT = Path(__file__).resolve().parent.parent / "assets" / "icon" / "app_icon.png"
RUSTORE = Path(__file__).resolve().parent.parent / "store_assets" / "rustore-logo-512.png"

BG = (17, 24, 39)  # #111827
MINT = (20, 184, 166)  # #14B8A6
PURPLE = (124, 58, 237)  # #7C3AED
BLUE = (59, 130, 246)  # #3B82F6


def lerp(a: int, b: int, t: float) -> int:
    return int(a + (b - a) * t)


def gradient_color(t: float) -> tuple[int, int, int]:
    t = max(0.0, min(1.0, t))
    if t < 0.5:
        u = t / 0.5
        return (
            lerp(MINT[0], BLUE[0], u),
            lerp(MINT[1], BLUE[1], u),
            lerp(MINT[2], BLUE[2], u),
        )
    u = (t - 0.5) / 0.5
    return (
        lerp(BLUE[0], PURPLE[0], u),
        lerp(BLUE[1], PURPLE[1], u),
        lerp(BLUE[2], PURPLE[2], u),
    )


def rounded_rect(draw: ImageDraw.ImageDraw, box, radius: int, fill) -> None:
    draw.rounded_rectangle(box, radius=radius, fill=fill)


def draw_logo() -> Image.Image:
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 255))
    draw = ImageDraw.Draw(img)

    pad = 48
    rounded_rect(draw, (pad, pad, SIZE - pad, SIZE - pad), 96, BG)

    # Glow
    glow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(glow)
    gdraw.ellipse((96, 96, 416, 416), fill=(20, 184, 166, 35))
    img = Image.alpha_composite(img, glow)
    draw = ImageDraw.Draw(img)

    cx, cy = SIZE // 2, SIZE // 2 + 8

    # P stem
    stem_w = 44
    stem = [
        (cx - 72, cy - 120),
        (cx - 72 + stem_w, cy - 120),
        (cx - 72 + stem_w, cy + 120),
        (cx - 72, cy + 120),
    ]
    draw.polygon(stem, fill=MINT)

    # P bowl + arrow (thick arc as polygon band)
    outer_r = 108
    inner_r = 58
    points_outer = []
    points_inner = []
    for deg in range(200, -70, -4):
        rad = math.radians(deg)
        points_outer.append(
            (cx - 28 + outer_r * math.cos(rad), cy - 20 + outer_r * math.sin(rad))
        )
    for deg in range(-70, 200, 4):
        rad = math.radians(deg)
        points_inner.append(
            (cx - 28 + inner_r * math.cos(rad), cy - 20 + inner_r * math.sin(rad))
        )

    # Color along arc
    bowl = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    bdraw = ImageDraw.Draw(bowl)
    ring = points_outer + points_inner
    bdraw.polygon(ring, fill=BLUE)

    # Arrow head
    ax, ay = cx + 62, cy - 118
    arrow = [(ax, ay), (ax + 54, ay - 28), (ax + 18, ay - 10)]
    bdraw.polygon(arrow, fill=PURPLE)

    img = Image.alpha_composite(img, bowl)

    # Subtle highlight on stem
    highlight = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    hdraw = ImageDraw.Draw(highlight)
    hdraw.line(
        [(cx - 58, cy - 110), (cx - 58, cy + 110)],
        fill=(255, 255, 255, 40),
        width=6,
    )
    img = Image.alpha_composite(img, highlight)

    return img.convert("RGB")


def main() -> None:
    logo = draw_logo()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    logo.save(OUT, "PNG", optimize=True)
    logo.save(RUSTORE, "PNG", optimize=True)
    print(f"Saved {OUT} ({OUT.stat().st_size} bytes)")
    print(f"Saved {RUSTORE} ({RUSTORE.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
