Plime — материалы для RuStore / магазинов
==========================================

ЛОГОТИП RuStore (1:1, 512×512, до 1 MB)
  store_assets/rustore-logo-512.png
  assets/icon/app_icon.png — тот же файл для APK/IPA

  Пересоздать логотип:
    python tool/generate_logo.py
    (или положить свой 512×512 PNG в assets/icon/app_icon.png)
    dart run flutter_launcher_icons
    python tool/sync_rustore_logo.py

СКРИНШОТЫ (store_assets/screenshots/)
  Реальные скрины из приложения (не AI):
  1. plime-screenshot-1-today.png      — вкладка «Сегодня»
  2. plime-screenshot-2-motivation.png — цель, серии, челленджи
  3. plime-screenshot-3-stats.png       — вкладка «Статистика»

  Пересоздать скрины:
    flutter build web --dart-define=DEMO_MODE=true --release
    cd build/web && python -m http.server 8765
    python tool/capture_screenshots.py

  Размер: 1170×2532 (9:19.5), подходит для RuStore.

RuStore:
  • Логотип: rustore-logo-512.png
  • Минимум 2 скриншота, рекомендуется 3–5
  • APK с новой иконкой из GitHub Actions
