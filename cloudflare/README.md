# Plime AI Coach — Cloudflare Workers AI

Бесплатный прокси для советов и цитат в приложении Plime.  
Ключ API **не** попадает в APK — только URL воркера.

## Что нужно сделать вам (один раз, ~10 минут)

### 1. Аккаунт Cloudflare
1. Зарегистрируйтесь на https://dash.cloudflare.com/sign-up (бесплатно).
2. Установите Wrangler (CLI):
   ```powershell
   npm install -g wrangler
   wrangler login
   ```

### 2. Деплой воркера

**Важно:** при первом деплое Wrangler спросит:
`Would you like to register a workers.dev subdomain now?`

Ответьте **`yes`** (не `no`). Это бесплатный адрес вида  
`https://plime-ai-coach.<ваш-ник>.workers.dev` — он нужен приложению.

Если уже ответили `no` и видите ошибку — зарегистрируйте поддомен вручную:
1. Откройте [Workers onboarding](https://dash.cloudflare.com/?to=/:account/workers/onboarding) в аккаунте Cloudflare.
2. Выберите любое свободное имя поддомена (например `addjukey` или `plime-app`).
3. Снова выполните деплой:

```powershell
cd "C:\Programming\пприложение\goal_path\cloudflare"
wrangler deploy
```

В конце появится URL вида:
`https://plime-ai-coach.<ваш-субдомен>.workers.dev`

Скопируйте его — это **AI_WORKER_URL**.

### 3. Сборка APK с ИИ
```powershell
cd "C:\Programming\пприложение\goal_path"
flutter build apk --release --dart-define=AI_WORKER_URL=https://plime-ai-coach.ВАШ.workers.dev
```

Для локальной разработки:
```powershell
flutter run --dart-define=AI_WORKER_URL=https://plime-ai-coach.ВАШ.workers.dev
```

### 4. GitHub Actions (опционально)
В Settings → Secrets добавьте:
- `AI_WORKER_URL` = ваш URL воркера

И в workflow добавьте к `flutter build apk`:
`--dart-define=AI_WORKER_URL=${{ secrets.AI_WORKER_URL }}`

---

## Лимиты (бесплатно)
- **10 000 Neurons/день** на Workers AI
- Короткий совет ≈ 10–30 Neurons → сотни–тысячи ответов в день
- В приложении: кэш + 35% офлайн-микс по умолчанию

---

## Без ИИ
Если URL не задан — работают **офлайн-цитаты** из `assets/data/quotes_ru.json`.  
В настройках: «Только офлайн-советы» или ползунок «Офлайн-микс».

---

## RuStore
В описании приложения укажите:
> Умные советы (опционально): отправляются только агрегированные цифры (суммы, часы, прогресс). Заметки не передаются. Можно отключить в настройках.

---

## Проверка воркера
```powershell
curl -X POST "https://plime-ai-coach.ВАШ.workers.dev" `
  -H "Content-Type: application/json" `
  -d '{"type":"quote","situation":"shiftSaved","context":{"goalTitle":"MacBook","shiftAmount":3500}}'
```

Ответ: `{"text":"..."}`
