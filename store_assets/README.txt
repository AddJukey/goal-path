Plime — материалы для RuStore / магазинов
==========================================

ЛОГОТИП RuStore (1:1, 512×512, до 1 MB)
  store_assets/rustore-logo-512.png
  assets/icon/app_icon.png — тот же файл для APK/IPA

  Пересоздать логотип:
    python tool/generate_logo.py
    dart run flutter_launcher_icons
    powershell store_assets/sync-rustore-logo.ps1

СКРИНШОТЫ ДЛЯ ВИТРИНЫ (store_assets/screenshots/)
  Маркетинговые скрины в стиле App Store (реальный UI + заголовки):
  1. plime-screenshot-1-today.png       — «Копи на свою мечту»
  2. plime-screenshot-2-progress.png    — «Отмечай каждую смену»
  3. plime-screenshot-3-motivation.png  — «Не теряй мотивацию»
  4. plime-screenshot-4-stats.png        — «Видь полную картину»
  5. plime-screenshot-5-badges.png      — «Получай награды»

  Исходники и превью:
    screenshots/raw/         — сырые кадры из приложения
    screenshots/marketing/   — финальные PNG + showcase.png

  Размер финалов: 1920×1080 (ландшафт, Full HD).

  Пересоздать весь набор:
    flutter build web --dart-define=DEMO_MODE=true --release
    cd build/web && python -m http.server 8765
    python tool/capture_screenshots.py
    python tool/render_landscape_screenshots.py

RuStore:
  • Логотип: rustore-logo-512.png
  • 5 скриншотов из screenshots/
  • APK с новой иконкой из GitHub Actions
