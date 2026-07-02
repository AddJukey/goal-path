/**
 * Plime AI Coach — Cloudflare Worker
 * Deploy: see README.md
 */

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

const SYSTEM = {
  quote: `Ты мотивационный коуч приложения Plime (трекер смен и целей).
Ответь ОДНОЙ фразой до 120 символов на русском, без кавычек и имён авторов.
Тон спокойный, поддерживающий. Используй только цифры из контекста.`,

  advice: `Ты коуч Plime. Дай один практический совет на русском — 2 коротких предложения.
Без токсичной мотивации. Только факты из контекста.`,

  mood: `Ты аналитик Plime. Объясни связь настроения/энергии и заработка — 2 предложения на русском.
Если данных мало — скажи мягко продолжать отмечать настроение.`,
};

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: CORS });
    }
    if (request.method !== 'POST') {
      return json({ error: 'POST only' }, 405);
    }

    let body;
    try {
      body = await request.json();
    } catch {
      return json({ error: 'Invalid JSON' }, 400);
    }

    const type = body.type || 'quote';
    const system = SYSTEM[type] || SYSTEM.quote;
    const user = JSON.stringify({
      situation: body.situation,
      context: body.context || {},
    });

    try {
      const result = await env.AI.run('@cf/meta/llama-3.1-8b-instruct', {
        messages: [
          { role: 'system', content: system },
          { role: 'user', content: user },
        ],
        max_tokens: 120,
      });

      const text = (result.response || '').trim();
      return json({ text }, 200);
    } catch (e) {
      return json({ error: String(e) }, 502);
    }
  },
};

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...CORS, 'Content-Type': 'application/json' },
  });
}
