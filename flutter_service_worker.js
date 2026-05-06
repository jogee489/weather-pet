'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/assets/lottie/dog/default/foggy.json": "d4c51ff95cc8130c53e6834b75beaa3b",
"assets/assets/lottie/dog/default/stormy.json": "972c1ae92cc2e40b90386b81d0e6b3cc",
"assets/assets/lottie/dog/default/hot.json": "c1b17908530fc4331f9746b3c6ea2980",
"assets/assets/lottie/dog/default/cloudy.json": "4ddc5885966c6e83dbc76500b4a93f8d",
"assets/assets/lottie/dog/default/rainy.json": "3acfe6cdb741733f1d5d48abf9aabea1",
"assets/assets/lottie/dog/default/cold.json": "1bfbd96b250a78137ea0f34e23092d23",
"assets/assets/lottie/dog/default/night.json": "c4f4aaaad24601e8ed01e6001ce9bab3",
"assets/assets/lottie/dog/default/sunny.json": "8e865f903b9b7903a3cf4bb9bf7ad676",
"assets/assets/lottie/dog/default/windy.json": "5a969cf6c071f812ba637b8c68e51ce9",
"assets/assets/lottie/dog/default/snowy.json": "9b3a258a81a5599e2a5016a0aff4bb7d",
"assets/assets/lottie/dog/default/loading.json": "d401ec6ba56fc2ce5bc94503abef9e5e",
"assets/assets/lottie/frog/default/foggy.json": "7ea46b0f5ce7baa56cf0a16de1c8d332",
"assets/assets/lottie/frog/default/stormy.json": "d6b23ba83fcea740cd16fd77e0adb7b6",
"assets/assets/lottie/frog/default/hot.json": "4ceec17a72090e576fc19213a3fdf8d6",
"assets/assets/lottie/frog/default/cloudy.json": "a612a4b024bb77831a042272fcedb1a6",
"assets/assets/lottie/frog/default/rainy.json": "754cf68a6e405eb8e49bb985a56e27a5",
"assets/assets/lottie/frog/default/cold.json": "1f7a8f938bbbc47cc46af3bce6d15a2c",
"assets/assets/lottie/frog/default/night.json": "76df5d0592313198c377cf01f86944a2",
"assets/assets/lottie/frog/default/sunny.json": "26621cf5afd52c20c0ef1635aaca2702",
"assets/assets/lottie/frog/default/windy.json": "5ab9a1bdb1d4c5d325c3f1210cd6a9e4",
"assets/assets/lottie/frog/default/snowy.json": "d4ee3de3186a71300a7f604c0e1d8ee4",
"assets/assets/lottie/frog/default/loading.json": "0ce5f542f52335b9fa29ff74b99f383c",
"assets/assets/lottie/dragon/default/foggy.json": "14ad170eb09b218f9029f2cf294b131f",
"assets/assets/lottie/dragon/default/stormy.json": "e3ccc5c1325f3f9f797e057e180ea1d6",
"assets/assets/lottie/dragon/default/hot.json": "69686cbd10fcfb1bb7b532385b240924",
"assets/assets/lottie/dragon/default/cloudy.json": "ee2fa535438f68c758fef913c7e70df6",
"assets/assets/lottie/dragon/default/rainy.json": "9283f2b00c9bcf7fced9c5ef7c29c5ae",
"assets/assets/lottie/dragon/default/cold.json": "3fed7601163c105e7976aa6169545f97",
"assets/assets/lottie/dragon/default/night.json": "ebab2fd390ef3e06e19eeab448317dd3",
"assets/assets/lottie/dragon/default/sunny.json": "28a5c631d2ca0b97c8bbce391f13317e",
"assets/assets/lottie/dragon/default/windy.json": "abadf125fbc2067dbedf8a540c4e2640",
"assets/assets/lottie/dragon/default/snowy.json": "b6e3e87f6d7cd9acafcba11319530817",
"assets/assets/lottie/dragon/default/loading.json": "3e087bc5cccaa63943505288eb0ae87a",
"assets/assets/lottie/cat/default/foggy.json": "b7b96b3460e61bf59d41b20b35e41950",
"assets/assets/lottie/cat/default/stormy.json": "ac957177db7a3a9bebccf97fca15c782",
"assets/assets/lottie/cat/default/hot.json": "a4d2cc949e6972cf98e6bd55250c6bfe",
"assets/assets/lottie/cat/default/cloudy.json": "abf349e65744812db0e813f9e0f893cb",
"assets/assets/lottie/cat/default/rainy.json": "6923a350809832d4971a48098fea9292",
"assets/assets/lottie/cat/default/cold.json": "a1636e153e8789b5a9aba64f56b696e0",
"assets/assets/lottie/cat/default/night.json": "1e07574929434995d3bb27dc8ebc05a7",
"assets/assets/lottie/cat/default/sunny.json": "84877148105f4306d4bc38df31870ba0",
"assets/assets/lottie/cat/default/windy.json": "5fe9232cac04a8394815950fc0594602",
"assets/assets/lottie/cat/default/snowy.json": "be0bb944e2c441238701b88606b21017",
"assets/assets/lottie/cat/default/loading.json": "f26f0753c00306c74f0bc55069e8921e",
"assets/AssetManifest.json": "8377505358b276c19c1960599be07fc4",
"assets/AssetManifest.bin.json": "36ba070616254e8422535c3911f6fa82",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/fonts/MaterialIcons-Regular.otf": "693f512d857f09b11a34341847711f1c",
"assets/AssetManifest.bin": "6ba6b9aa981a237b511c1f87debd7a83",
"assets/NOTICES": "5664183e2febdd24c30d229c55f10409",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"manifest.json": "f0a87ef99757fbe4b0bef97163defc8f",
"index.html": "b17a8df11fbeb668d676428bb318fd5c",
"/": "b17a8df11fbeb668d676428bb318fd5c",
"canvaskit/skwasm.js.symbols": "c3c05bd50bdf59da8626bbe446ce65a3",
"canvaskit/chromium/canvaskit.js.symbols": "ee7e331f7f5bbf5ec937737542112372",
"canvaskit/chromium/canvaskit.wasm": "399e2344480862e2dfa26f12fa5891d7",
"canvaskit/chromium/canvaskit.js": "901bb9e28fac643b7da75ecfd3339f3f",
"canvaskit/canvaskit.js.symbols": "74a84c23f5ada42fe063514c587968c6",
"canvaskit/skwasm.wasm": "4051bfc27ba29bf420d17aa0c3a98bce",
"canvaskit/canvaskit.wasm": "9251bb81ae8464c4df3b072f84aa969b",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"canvaskit/canvaskit.js": "738255d00768497e86aa4ca510cce1e1",
"canvaskit/skwasm.js": "5d4f9263ec93efeb022bb14a3881d240",
"flutter.js": "383e55f7f3cce5be08fcf1f3881f585c",
"flutter_bootstrap.js": "74532cac751f67a3479c1cdbfd2d58a0",
"main.dart.js": "adaa0cb48f731c0db3ad296e741e86b2",
"version.json": "2a2e70a5cb7d4b9199ceb6b09989b6f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
