# Путь к цели — установка на iPhone без Mac

Приложение на **Flutter**. Сборка IPA через **GitHub Actions** (бесплатно), установка через **AltStore** (бесплатный Apple ID).

## Схема

```
Windows (разработка)  →  GitHub  →  macOS runner (сборка IPA)  →  AltStore  →  iPhone
```

Платный Apple Developer ($99/год) **не нужен**.

---

## 1. Подготовка проекта на Windows

```powershell
cd "C:\Programming\пприложение\goal_path"
flutter pub get
flutter run -d web-server
```

Открой ссылку из терминала — проверь UI в браузере.

---

## 2. Загрузка на GitHub

Репозиторий должен быть **в папке `goal_path`** (корень = Flutter-проект).

```powershell
cd "C:\Programming\пприложение\goal_path"
git init
git add .
git commit -m "Initial commit: Goal Path app"
```

Создай репозиторий на [github.com/new](https://github.com/new) (например `goal-path`), затем:

```powershell
git branch -M main
git remote add origin https://github.com/ТВОЙ_ЛОГИН/goal-path.git
git push -u origin main
```

> **Важно:** не коммить папки `build/`, `.dart_tool/` — они уже в `.gitignore`.

---

## 3. Сборка IPA в GitHub Actions

Workflow уже лежит в `.github/workflows/build-ios.yml`.

### Автоматически
При каждом `push` в ветку `main` запускается сборка (~15–25 мин).

### Вручную
1. GitHub → твой репозиторий → **Actions**
2. **Build iOS IPA (unsigned, for AltStore)** → **Run workflow**

### Скачать IPA
1. Открой завершённый workflow run (зелёная галочка)
2. Внизу секция **Artifacts** → **goal-path-ios-ipa**
3. Скачай ZIP → внутри файл `goal-path-unsigned.ipa`

### Лимиты GitHub
| Тип репозитория | macOS минуты |
|-----------------|--------------|
| Public (открытый) | ~2000 мин/мес бесплатно |
| Private (закрытый) | ~200 мин/мес (macOS ×10) |

Для экономии минут используй **Run workflow** вручную, а не push при каждом изменении.

---

## 4. AltStore — установка на iPhone

### На Windows
1. Скачай [AltServer for Windows](https://altstore.io/#Downloads)
2. Установи **iCloud** и **iTunes** (Microsoft Store) — нужны для связи с iPhone
3. Подключи iPhone по USB или Wi‑Fi
4. Запусти AltServer → иконка в трее → **Install AltStore** → выбери iPhone
5. На iPhone: **Настройки → Основные → VPN и управление устройством** → доверь разработчику

### Установка приложения
1. Скопируй `goal-path-unsigned.ipa` на iPhone (Files, Telegram, iCloud Drive)
2. Открой **AltStore** → вкладка **My Apps** → **+**
3. Выбери `.ipa` файл
4. Введи свой **Apple ID** — AltStore подпишет приложение

### Ограничения бесплатного Apple ID
- приложение работает **7 дней**, потом переустанови через AltStore
- максимум **3 приложения** одновременно (не считая AltStore)
- AltServer на ПК должен быть запущен раз в 7 дней для обновления подписи (или включи **Background Refresh** для AltStore)

---

## 5. Обновление приложения

```powershell
# на Windows — правки кода
git add .
git commit -m "Update"
git push
```

→ дождись сборки в Actions → скачай новый IPA → установи через AltStore поверх старой версии.

---

## Codemagic (опционально)

Файл `codemagic.yaml` оставлен на случай, если купишь **Apple Developer Program** ($99/год).  
С бесплатным Apple ID Codemagic **не подходит** — нужен App Store Connect API key.

---

## Структура проекта

```
goal_path/
├── lib/                        — код приложения
├── ios/                        — iOS-проект (нужен для сборки)
├── .github/workflows/
│   └── build-ios.yml           — сборка IPA
├── setup.ps1                   — первый запуск на Windows
└── BUILD.md                    — эта инструкция
```

---

## Частые проблемы

| Проблема | Решение |
|----------|---------|
| Actions не запускается | Проверь, что push в ветку `main` и workflow файл в репозитории |
| Сборка упала на CocoaPods | Запусти локально `flutter create . --platforms=ios` и закоммить `ios/` |
| AltStore «Unable to install» | Перезапусти AltServer, проверь что iPhone и ПК в одной Wi‑Fi сети |
| Приложение перестало открываться | Прошло 7 дней — переустанови через AltStore |
| «Maximum apps installed» | Удали одно из 3 sideload-приложений в AltStore |
