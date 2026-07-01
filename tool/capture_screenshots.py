"""Capture real Plime screenshots from local web build."""
from __future__ import annotations

import time
from pathlib import Path

from PIL import Image
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

BASE = "http://localhost:8765"
OUT_DIR = Path(__file__).resolve().parent.parent / "store_assets" / "screenshots"
WIDTH, HEIGHT = 390, 844
SCALE = 3  # 1170x2532 for RuStore quality


def capture(url: str, path: Path) -> None:
    options = Options()
    options.add_argument("--headless=new")
    options.add_argument("--hide-scrollbars")
    options.add_argument(f"--force-device-scale-factor={SCALE}")
    options.add_argument("--disable-gpu")
    options.add_argument(f"--window-size={WIDTH},{HEIGHT}")

    driver = webdriver.Chrome(options=options)
    try:
        driver.get(url)
        time.sleep(4)
        path.parent.mkdir(parents=True, exist_ok=True)
        driver.save_screenshot(str(path.with_suffix(".tmp.png")))
    finally:
        driver.quit()

    # Trim to exact 9:16 if needed
    img = Image.open(path.with_suffix(".tmp.png"))
    img = img.convert("RGB")
    target_w, target_h = WIDTH * SCALE, HEIGHT * SCALE
    if img.size != (target_w, target_h):
        img = img.crop((0, 0, min(target_w, img.width), min(target_h, img.height)))
        img = img.resize((target_w, target_h), Image.Resampling.LANCZOS)
    img.save(path, "PNG", optimize=True)
    path.with_suffix(".tmp.png").unlink(missing_ok=True)
    print(f"Saved {path} ({img.size[0]}x{img.size[1]})")


def main() -> None:
    shots = [
        (f"{BASE}/", OUT_DIR / "plime-screenshot-1-today.png"),
        (f"{BASE}/?scroll=900", OUT_DIR / "plime-screenshot-2-motivation.png"),
        (f"{BASE}/?tab=stats", OUT_DIR / "plime-screenshot-3-stats.png"),
    ]
    for url, path in shots:
        capture(url, path)


if __name__ == "__main__":
    main()
