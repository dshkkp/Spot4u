# Постоянный HTTPS-хост Spot4u

Временный `trycloudflare.com` нужен только для preview. Для постоянной установки PWA на iPhone используйте один домен с Caddy: Web и `/api` будут на одном origin, поэтому CORS не нужен, а PostgreSQL останется внутри Docker-сети.

## Что нужно

- Linux-сервер с Docker, Docker Compose, Python 3 и Flutter 3.50.1.
- Домен `spot4u.example.com` с A/AAAA-записью на сервер.
- Открытые порты 80 и 443 только для Caddy.
- Порт 5432 закрыт снаружи сервера. Backend на 8000 и preview на 3000 слушают только localhost или изолированную сеть.

## Запуск

```bash
git clone https://github.com/ashromanov/spot4u.git
cd spot4u
docker compose up --build -d
python3 scripts/build_web.py
```

Preview использует только стандартную библиотеку Python и должен работать постоянно под systemd или supervisor, а не в интерактивном shell:

```bash
python3 scripts/serve_preview.py
```

Пример `Caddyfile`:

```caddy
spot4u.example.com {
    reverse_proxy 127.0.0.1:3000
    encode gzip
}
```

Caddy автоматически получает и продлевает сертификат. Перед первым запуском убедитесь, что DNS указывает на сервер, а порты 8000/3000/5432 недоступны из интернета напрямую.

Проверка с сервера:

```bash
curl http://127.0.0.1:3000/health
curl https://spot4u.example.com/health
python3 scripts/verify_backend.py
```

`SPOT4U_API_URL` по умолчанию использует `/`, поэтому мобильные клиенты обращаются к API на том же домене. `index.html` и bootstrap получают `no-cache`, hashed-ассеты — `max-age=31536000, immutable`.

## Обновление

```bash
cd spot4u
git pull
docker compose up --build -d
.venv/bin/python scripts/build_web.py
systemctl restart spot4u-preview
```

Имя `spot4u-preview` приведено как пример systemd unit. Обновление не меняет места в PostgreSQL и не требует повторного импорта вручную: importer запускается из Compose и использует upsert.

## iPhone

1. Откройте `https://spot4u.example.com` в Safari.
2. Дождитесь первой загрузки и установки Service Worker.
3. Выберите «Поделиться» → «На экран “Домой”».
4. Запустите Spot4u с иконки. Новый поиск требует сеть, сохранённая оболочка открывается и offline.

Quick tunnel можно остановить после проверки постоянного домена.
