"""Capture full-viewport Plime screenshots from local web build."""
from __future__ import annotations

import time
from pathlib import Path

from PIL import Image
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

BASE = "http://localhost:8765"
RAW_DIR = Path(__file__).resolve().parent.parent / "store_assets" / "screenshots" / "raw"
LOGICAL_W, LOGICAL_H = 390, 844
PIXEL_RATIO = 3
OUT_W, OUT_H = LOGICAL_W * PIXEL_RATIO, LOGICAL_H * PIXEL_RATIO


def capture(url: str, path: Path) -> None:
    options = Options()
    options.add_argument("--headless=new")
    options.add_argument("--hide-scrollbars")
    options.add_argument("--disable-gpu")
    options.add_argument("--force-device-scale-factor=1")
    options.add_experimental_option(
        "mobileEmulation",
        {
            "deviceMetrics": {
                "width": LOGICAL_W,
                "height": LOGICAL_H,
                "pixelRatio": PIXEL_RATIO,
            }
        },
    )

    driver = webdriver.Chrome(options=options)
    try:
        driver.get(url)
        time.sleep(4)
        path.parent.mkdir(parents=True, exist_ok=True)
        tmp = path.with_suffix(".tmp.png")
        driver.save_screenshot(str(tmp))
    finally:
        driver.quit()

    img = Image.open(tmp).convert("RGB")
    # Keep native capture size; only center-crop if browser added extra chrome.
    if img.width >= OUT_W and img.height >= OUT_H:
        left = (img.width - OUT_W) // 2
        top = (img.height - OUT_H) // 2
        img = img.crop((left, top, left + OUT_W, top + OUT_H))
    elif img.size != (OUT_W, OUT_H):
        img = img.resize((OUT_W, OUT_H), Image.Resampling.LANCZOS)

    img.save(path, "PNG", optimize=True)
    tmp.unlink(missing_ok=True)
    print(f"Saved {path} ({img.size[0]}x{img.size[1]})")


def main() -> None:
    shots = [
        (f"{BASE}/", RAW_DIR / "01-today.png"),
        (f"{BASE}/?scroll=520", RAW_DIR / "02-progress.png"),
        (f"{BASE}/?scroll=1050", RAW_DIR / "03-motivation.png"),
        (f"{BASE}/?tab=stats", RAW_DIR / "04-stats.png"),
        (f"{BASE}/?tab=stats&scroll=620", RAW_DIR / "05-badges.png"),
    ]
    for url, path in shots:
        capture(url, path)


if __name__ == "__main__":
    main()
