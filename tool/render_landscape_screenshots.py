"""Compose sharp 1920x1080 landscape store screenshots from raw app captures."""
from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
RAW_DIR = ROOT / "store_assets" / "screenshots" / "raw"
OUT_DIR = ROOT / "store_assets" / "screenshots" / "marketing"
STORE_DIR = ROOT / "store_assets" / "screenshots"

W, H = 1920, 1080
PHONE_MAX_H = 940
PHONE_X = 1040
MINT = (94, 234, 212)
WHITE = (248, 250, 252)
SLATE = (148, 163, 184)

SHOTS = [
    ("01-today.png", "01-kopi-na-mechtu.png", "plime-screenshot-1-today.png",
     "Копи на свою мечту", "Умный трекер целей и смен"),
    ("02-progress.png", "02-otmechaj-smenu.png", "plime-screenshot-2-progress.png",
     "Отмечай каждую смену", "Часы, заработок и прогресс"),
    ("03-motivation.png", "03-motivaciya.png", "plime-screenshot-3-motivation.png",
     "Не теряй мотивацию", "Серии, челленджи и прогноз"),
    ("04-stats.png", "04-statistika.png", "plime-screenshot-4-stats.png",
     "Видь полную картину", "Графики, прогнозы и аналитика"),
    ("05-badges.png", "05-nagrady.png", "plime-screenshot-5-badges.png",
     "Получай награды", "За каждую веху на пути к цели"),
]


def _font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "C:/Windows/Fonts/segoeuib.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf",
        "C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf",
    ]
    for path in candidates:
        if Path(path).exists():
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def _gradient_bg() -> Image.Image:
    img = Image.new("RGB", (W, H))
    draw = ImageDraw.Draw(img)
    for y in range(H):
        t = y / (H - 1)
        r = int(15 + t * (30 - 15))
        g = int(23 + t * (58 - 23))
        b = int(42 + t * (95 - 42))
        draw.line([(0, y), (W, y)], fill=(r, g, b))
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(glow)
    gdraw.ellipse((PHONE_X - 180, H // 2 - 420, PHONE_X + 620, H // 2 + 420),
                  fill=(20, 184, 166, 38))
    glow = glow.filter(ImageFilter.GaussianBlur(80))
    return Image.alpha_composite(img.convert("RGBA"), glow).convert("RGB")


def _rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size[0], size[1]), radius=radius, fill=255)
    return mask


def _place_phone(canvas: Image.Image, screen: Image.Image) -> None:
    sw, sh = screen.size
    scale = PHONE_MAX_H / sh
    pw, ph = int(sw * scale), int(sh * scale)
    screen_fit = screen.resize((pw, ph), Image.Resampling.LANCZOS)

    bezel = 14
    frame_w, frame_h = pw + bezel * 2, ph + bezel * 2
    fx = PHONE_X + (520 - frame_w) // 2
    fy = (H - frame_h) // 2
    radius = max(36, int(48 * scale))

    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow)
    sdraw.rounded_rectangle(
        (fx + 10, fy + 18, fx + frame_w + 10, fy + frame_h + 18),
        radius=radius + 4,
        fill=(0, 0, 0, 90),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(24))
    canvas.alpha_composite(shadow)

    frame = Image.new("RGBA", (frame_w, frame_h), (24, 30, 42, 255))
    frame_mask = _rounded_mask((frame_w, frame_h), radius)
    canvas.paste(frame, (fx, fy), frame_mask)

    screen_mask = _rounded_mask((pw, ph), max(28, radius - 6))
    canvas.paste(screen_fit, (fx + bezel, fy + bezel), screen_mask)


def _draw_text(canvas: Image.Image, headline: str, sub: str) -> None:
    draw = ImageDraw.Draw(canvas)
    x = 96

    draw.rounded_rectangle((x, 118, x + 118, 158), radius=20, fill=(20, 184, 166))
    draw.text((x + 22, 126), "plime", fill=WHITE, font=_font(22, bold=True))

    title_font = _font(62, bold=True)
    sub_font = _font(30)

    lines = _wrap(draw, headline, title_font, 780)
    y = 210
    for line in lines:
        draw.text((x, y), line, fill=WHITE, font=title_font)
        y += 72

    draw.text((x, y + 18), sub, fill=MINT, font=sub_font)

    draw.text((x, H - 72), "Plime", fill=SLATE, font=_font(22))


def _wrap(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.ImageFont, max_w: int) -> list[str]:
    words = text.split()
    lines: list[str] = []
    current = ""
    for word in words:
        trial = f"{current} {word}".strip()
        if draw.textlength(trial, font=font) <= max_w:
            current = trial
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines or [text]


def render_one(raw_name: str, out_name: str, headline: str, sub: str) -> Path:
    raw = Image.open(RAW_DIR / raw_name).convert("RGBA")
    canvas = _gradient_bg().convert("RGBA")
    _draw_text(canvas, headline, sub)
    _place_phone(canvas, raw)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out = OUT_DIR / out_name
    final = canvas.convert("RGB")
    final.save(out, "PNG", optimize=True)
    return out


def _make_showcase(paths: list[Path]) -> None:
    thumb_h = 360
    gap = 24
    pad = 40
    thumbs: list[Image.Image] = []
    for p in paths:
        im = Image.open(p).convert("RGB")
        tw = int(im.width * thumb_h / im.height)
        thumbs.append(im.resize((tw, thumb_h), Image.Resampling.LANCZOS))
    total_w = pad * 2 + sum(t.width for t in thumbs) + gap * (len(thumbs) - 1)
    row = Image.new("RGB", (total_w, thumb_h + pad * 2 + 40), (15, 23, 42))
    x = pad
    for t in thumbs:
        row.paste(t, (x, pad))
        x += t.width + gap
    ImageDraw.Draw(row).text((pad, thumb_h + pad + 8), "Plime — трекер целей и смен",
                             fill=SLATE, font=_font(20))
    row.save(OUT_DIR / "showcase.png", "PNG", optimize=True)


def main() -> None:
    outputs: list[Path] = []
    for raw, out, store_name, headline, sub in SHOTS:
        path = render_one(raw, out, headline, sub)
        store_path = STORE_DIR / store_name
        Image.open(path).save(store_path, "PNG", optimize=True)
        outputs.append(path)
        print(f"{path} ({W}x{H}) -> {store_path}")

    _make_showcase(outputs)


if __name__ == "__main__":
    main()
