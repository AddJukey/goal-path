Plime — материалы для RuStore / магазинов
==========================================

ЛОГОТИП RuStore (1:1, сторона 32–512 px, до 1 MB)
  store_assets/rustore-logo-512.png   — 512×512, копия иконки из APK
  ВАЖНО: должен совпадать с иконкой в APK! После смены иконки:
    dart run flutter_launcher_icons
    .\store_assets\sync-rustore-logo.ps1
  Загружайте в RuStore ТОЛЬКО этот файл, не другую картинку.

ИКОНКА приложения (в APK/IPA)
  assets/icon/app_icon.png          — исходник 1024×1024
  После `dart run flutter_launcher_icons` иконки появятся в android/ и ios/

СКРИНШОТЫ (store_assets/screenshots/)
  1. plime-screenshot-1-today.png   — вкладка «Сегодня», календарь, смена
  2. plime-screenshot-2-stats.png   — вкладка «Статистика», графики
  3. plime-screenshot-3-goals.png   — цель, серии, челленджи

RuStore (Android):
  • Минимум 2 скриншота, рекомендуется 4–8
  • Соотношение 9:16 или 9:19.5, от 720 px по короткой стороне
  • Формат PNG или JPEG

Совет: для публикации лучше заменить на реальные скрины с телефона
(Настройки → сделать скриншот в приложении). Сгенерированные — для черновика.

Генерация иконок на проекте:
  flutter pub get
  dart run flutter_launcher_icons
