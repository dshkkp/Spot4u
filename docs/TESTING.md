# Проверка Spot4u

## Единая команда

```bash
python3 scripts/check.py
```

Нужны Docker, Flutter, Python-зависимости из `backend/requirements-dev.txt` и Chromium. При нестандартном пути к Flutter используйте `FLUTTER_BIN=/полный/путь/flutter`.

Команда выполняет:

1. Запуск PostgreSQL, импорт и API через Docker Compose.
2. 13 Backend unit-тестов и интеграционные проверки всех фильтров/сортировок.
3. Повторный импорт и повторную проверку API — 104 записи без дубликатов.
4. `flutter analyze` и 15 unit/widget-тестов.
5. Live API test мобильного клиента с реальным Backend, который в обычном `flutter test` пропускается.
6. PWA-сборку с content hash, gzip и собственным Service Worker.
7. Web E2E в Chromium с 13 скриншотами, проверкой запросов ползунков и JavaScript-исключений.

Команды ручной сборки Android и iOS приведены в README. Для сборки iOS нужен Mac с Xcode.

## Проверенные результаты

- Backend: 13/13 тестов, StudyScore `80.83`, hard filters, unknown/null, часы Europe/Moscow, повторный импорт.
- Flutter: 15/15 тестов, отдельный live API test против реального Backend.
- Web E2E: S1, S1a, S2, S2b, S3, S3a, S4, S5, S6, S7, второй корпус и пустая категория. Ползунок формирует запрос с `1050`, затем с `null`; приоритеты доступны в S4. Результат: 58 мест для начальных категорий Ленинградского и 27 для Вешняковского, 0 JavaScript-исключений.
- PWA: `sw.js` контролирует страницу, `spot4u-static-v3` существует, после offline-reload приложение запускается, 0 исключений. На медленной сети первый кадр показывает полноэкранный градиентный loader.
- Safari на macOS runner: S1, S1a, S2, S2b, S3, S3a, S4, S6, S7, второй корпус, валидация и offline reload; 58/27 мест, 0 JavaScript-ошибок. Все 13 скриншотов визуально отсмотрены.
- Android на эмуляторе 320×640: оба корпуса, выпадающее меню, ползунки до значения и обратно к максимуму, раскрытая карточка, карта с жестами, приоритеты в S4, S6, S7 и восстановление API. Результат: 58/27 мест; визуально отсмотрены 13 состояний.
- Mermaid: все четыре диаграммы из `ARCHITECTURE.md` успешно отрендерены Mermaid CLI.

Физический iPhone пока не заявляется как пройденная ручная проверка. PWA и iPhone-размеры проверены в браузере, нативная iOS-сборка — на macOS runner. Установка «На экран “Домой”» на физическом устройстве остаётся отдельным ручным этапом.

## Скриншоты Chromium, 390×844

- [Первый кадр с градиентом на медленной сети](visual/web/startup-gradient.jpg)
- [S1 — главная](visual/web/s1-home.png)
- [S1a — фильтры на главной](visual/web/s1a-inline-filters.png)
- [S5 — загрузка при задержке сети 2 с](visual/web/s5-loading.png)
- [S2 — список](visual/web/s2-list.png)
- [S2b — раскрытая карточка](visual/web/s2b-expanded-card.png)
- [S3 — карта](visual/web/s3-map.png)
- [S3a — выбранный маркер](visual/web/s3a-selected-marker.png)
- [S4 — фильтры](visual/web/s4-filters.png)
- [S4 — приоритеты и максимум ползунков](visual/web/s4-priorities.png)
- [S6 — пустая выдача с котом](visual/web/s6-empty.png)
- [S7 — техническая ошибка](visual/web/s7-error.png)
- [Вешняковский корпус](visual/web/s2-second-campus.png)
- [Валидация пустого набора категорий](visual/web/s1-validation.png)

## Скриншоты Safari, 390×792

- [S1 — главная](visual/safari/s1-home.png)
- [S1a — фильтры на главной](visual/safari/s1a-inline-filters.png)
- [S2 — список](visual/safari/s2-list.png)
- [S2b — раскрытая карточка](visual/safari/s2b-expanded-card.png)
- [S3 — карта](visual/safari/s3-map.png)
- [S3a — выбранный маркер](visual/safari/s3a-selected-marker.png)
- [S4 — фильтры](visual/safari/s4-filters.png)
- [S4 — приоритеты на увеличенном viewport 390×1200](visual/safari/s4-priorities.png)
- [S6 — пустая выдача с котом](visual/safari/s6-empty.png)
- [S7 — техническая ошибка](visual/safari/s7-error.png)
- [Вешняковский корпус](visual/safari/s2-second-campus.png)
- [Валидация пустого набора категорий](visual/safari/s1-validation.png)
- [Автономный запуск PWA](visual/safari/pwa-offline.png)

## Скриншоты Android-эмулятора, 320×640

- [S1 — главная](visual/android/s1-home.png)
- [Выбор корпуса](visual/android/s1-campus-menu.png)
- [S1a — фильтры на главной](visual/android/s1a-filters.png)
- [S2 — список](visual/android/s2-list.png)
- [S2b — раскрытая карточка](visual/android/s2b-expanded-card.png)
- [S3 — карта](visual/android/s3-map.png)
- [S3a — компактная карточка на карте](visual/android/s3a-selected-marker.png)
- [S3b — подробности на карте](visual/android/s3b-expanded-map-card.png)
- [S4 — приоритеты](visual/android/s4-priorities.png)
- [S6 — пустая выдача с котом](visual/android/s6-empty.png)
- [S7 — техническая ошибка с котом](visual/android/s7-error.png)
- [Восстановление после ошибки](visual/android/s7-recovered.png)
- [Вешняковский корпус](visual/android/s2-second-campus.png)

## Метрики preview

Замеры через временный Cloudflare tunnel из текущего окружения; они не являются обещанием одинаковой скорости на любом устройстве.

- Hashed JavaScript entrypoint: 2 674 041 байт до сжатия и 785 837 байт после gzip — примерно на 71% меньше, 1,92 с на скачивание.
- Backend search для 56 кофеен: 0,87 с полного HTTP-запроса.
- Повторный запуск PWA offline: интерфейс открыт из кэша без JavaScript-ошибок.
- Offline precache v3 содержит 36 актуальных файлов движка и занимает 8,08 МБ в gzip после удаления старых дубликатов.
- Hashed-ассеты отдаются с `Cache-Control: max-age=31536000, immutable`; `index.html`, bootstrap и API — с `no-cache`.
- Системный возврат проверен через `maybePop`: S4 закрывается без применения, затем выполняется возврат на S1 с сохранением настроек. Переходы между состояниями — 180 ms, раскрытие карточки карты — 220 ms.
- Список ↔ карта переключаются без нового запроса. Быстрые повторные нажатия блокируются одним активным поиском.

Для долгосрочной работы нужен постоянный HTTPS-хост Web и Backend: quick tunnel предназначен только для проверки и не имеет гарантии uptime.
