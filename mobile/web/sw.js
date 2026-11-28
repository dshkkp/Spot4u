const CACHE_NAME = '__SPOT4U_CACHE_NAME__';
const APPLICATION_SHELL = [
  './',
  'index.html',
  'manifest.json',
  'icons/Icon-180.png',
  'icons/Icon-192.png',
  'icons/Icon-512.png',
  'splash/splash-1170x2532.png',
  'splash/splash-1179x2556.png',
  'splash/splash-1125x2436.png',
  'splash/splash-1242x2688.png',
  'splash/splash-1284x2778.png',
  'splash/splash-1290x2796.png',
  'splash/splash-750x1334.png',
];

self.addEventListener('install', (event) => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE_NAME);
    await cache.addAll([...APPLICATION_SHELL, 'flutter_bootstrap.js']);
    const response = await fetch('precache_manifest.json');
    const manifest = await response.json();
    const isChromium = /Chrome|Chromium/.test(navigator.userAgent) && !/CriOS/.test(navigator.userAgent);
    const engineAssets = manifest.entries
      .filter((entry) => {
        const isUnused = entry.url.includes('skwasm') || entry.url.includes('wimp') || entry.url.includes('webparagraph');
        const isOtherEngine = entry.url.includes('canvaskit/') && (isChromium ? !entry.url.includes('chromium/') : entry.url.includes('chromium/'));
        return !isUnused && !isOtherEngine;
      })
      .map((entry) => entry.url);
    await cache.addAll(engineAssets);
    await self.skipWaiting();
  })());
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const names = await caches.keys();
    await Promise.all(names.filter((name) => name !== CACHE_NAME).map((name) => caches.delete(name)));
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  const url = new URL(request.url);
  if (request.method !== 'GET' || url.origin !== self.location.origin || url.pathname.startsWith('/api/') || url.pathname === '/health') return;

  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request)
        .then(async (response) => {
          const cache = await caches.open(CACHE_NAME);
          await cache.put('index.html', response.clone());
          return response;
        })
        .catch(async () => (await caches.open(CACHE_NAME)).match('index.html')),
    );
    return;
  }

  if (url.pathname.endsWith('/flutter_bootstrap.js')) {
    event.respondWith((async () => {
      const cache = await caches.open(CACHE_NAME);
      try {
        const response = await fetch(request);
        await cache.put(request, response.clone());
        return response;
      } catch {
        return cache.match(request);
      }
    })());
    return;
  }

  event.respondWith((async () => {
    const cache = await caches.open(CACHE_NAME);
    const cached = await cache.match(request, { ignoreSearch: true });
    if (cached) return cached;
    const response = await fetch(request);
    if (response.ok && response.type === 'basic') {
      const cache = await caches.open(CACHE_NAME);
      await cache.put(request, response.clone());
    }
    return response;
  })());
});
