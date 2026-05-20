'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/assets/images/dog/hot.png": "1ab8ac9d7880dd27e2be276e4ccafcbb",
"assets/assets/images/dog/loading.png": "e2224582a28c625a1233e81ad5ac244d",
"assets/assets/images/dog/windy.png": "f8955d3366ae4d03888ce5d679fb3ac4",
"assets/assets/images/dog/night.png": "3ce9db29294f1bb52e13ffe75ace1f52",
"assets/assets/images/dog/cloudy.png": "9cc57bf83764536c38c2d475270d1c96",
"assets/assets/images/dog/stormy.png": "4868a6001bc601ae7f1c7b5dd833dfaf",
"assets/assets/images/dog/cold.png": "68f25b7be6b5daff4193930508dfab89",
"assets/assets/images/dog/foggy.png": "7ae322ffbe7127f5dcdce91238b7485a",
"assets/assets/images/dog/rainy.png": "fe5b3af7f0a3c26edd1c41c2f7c74468",
"assets/assets/images/dog/sunny.png": "45c413a791dbc3f96a2416f45cbcba65",
"assets/assets/images/dog/snowy.png": "4248495b9d7f0bff7fb4664b5511f668",
"assets/assets/images/frog/hot.png": "af13d05d3c7d5fb12369e20c6358877b",
"assets/assets/images/frog/loading.png": "93fc113570c219d9cb619b97e75676b1",
"assets/assets/images/frog/windy.png": "32d4ce7ece3a6753ffcb83d93898cbe2",
"assets/assets/images/frog/night.png": "2af39007af3137676d0af9ccfad7b224",
"assets/assets/images/frog/cloudy.png": "253ac4b68b4186e5b98697916dc52105",
"assets/assets/images/frog/stormy.png": "b2da6f41a47926c0cd5af2e53c01f4da",
"assets/assets/images/frog/cold.png": "92b3ea043250af9619c9daea65d1eded",
"assets/assets/images/frog/foggy.png": "ef8f058ec8f4ee0734effd8aec7d6c7f",
"assets/assets/images/frog/rainy.png": "26bbc1107062dc80d5b64c19f8184927",
"assets/assets/images/frog/sunny.png": "0806f7227cc6f719794ab5797f93ac75",
"assets/assets/images/frog/snowy.png": "2f13f7dc12422ecf559aa70d8668b093",
"assets/assets/images/dragon/hot.png": "515fcf2085b59f0cdc90d903b74e3799",
"assets/assets/images/dragon/loading.png": "be9207e80a6b6be211c25e6224d72103",
"assets/assets/images/dragon/windy.png": "4c6845b9bc1eaa675591ae84ad658839",
"assets/assets/images/dragon/night.png": "eb75b7ffcd8c3988786df0e6641290b8",
"assets/assets/images/dragon/cloudy.png": "b701d63cabd86f9e4a5ba687f20c991e",
"assets/assets/images/dragon/stormy.png": "d9e0b97cf62b25c4bf299f9991db8d11",
"assets/assets/images/dragon/cold.png": "b0ca49a2a30423f519bb0dfa5587b3be",
"assets/assets/images/dragon/foggy.png": "44d2f68fd32b71fc2d856e05513d5aa6",
"assets/assets/images/dragon/rainy.png": "9dcd7d3282c1609aaae1c8e663f1efaa",
"assets/assets/images/dragon/sunny.png": "b824fd195eaebd30101ac37140eba4e5",
"assets/assets/images/dragon/snowy.png": "1de5526e1ce9a839f338494f1bcafe2a",
"assets/assets/images/cat/hot.png": "a804ff1342172976ec3497ab77453730",
"assets/assets/images/cat/loading.png": "572f9efe6647d4ac5554dfb37a5ebf07",
"assets/assets/images/cat/loading_alt.png": "89e5a315310760a50cd6178bd953a07f",
"assets/assets/images/cat/windy.png": "b426ddef55d9e1df8acb1d8ec8886363",
"assets/assets/images/cat/night.png": "4587656c7f70d54a7c64df5622101d04",
"assets/assets/images/cat/cloudy.png": "0a5d73376a63b3f4aeb9aef0c1190a5c",
"assets/assets/images/cat/stormy.png": "a0fdfdb7c7e567cac6576d274a0153dc",
"assets/assets/images/cat/cold.png": "f421d188b27c57f8dba6aa654c7c4385",
"assets/assets/images/cat/foggy.png": "2fc19bf3d30cb9709f0b6e8aa452ac1f",
"assets/assets/images/cat/rainy.png": "0bbe9b79473f50488b534e52d02a68b9",
"assets/assets/images/cat/sunny.png": "45bea02acb57198753d7b3492144427d",
"assets/assets/images/cat/snowy.png": "3320db354f3fdc5b0b35d9a325800568",
"assets/fonts/MaterialIcons-Regular.otf": "693f512d857f09b11a34341847711f1c",
"assets/AssetManifest.bin": "87e76912b695e8882a48acd27a482e78",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/AssetManifest.bin.json": "a3903a47ca6bb2d61e022a520b6f168d",
"assets/NOTICES": "d9e79eae1daac3b0d7470d83d864ddb4",
"assets/AssetManifest.json": "01e4cd971a9f82080dbd1ac657fe3580",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"version.json": "2a2e70a5cb7d4b9199ceb6b09989b6f1",
"index.html": "b17a8df11fbeb668d676428bb318fd5c",
"/": "b17a8df11fbeb668d676428bb318fd5c",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"flutter.js": "383e55f7f3cce5be08fcf1f3881f585c",
"canvaskit/canvaskit.wasm": "9251bb81ae8464c4df3b072f84aa969b",
"canvaskit/skwasm.js.symbols": "c3c05bd50bdf59da8626bbe446ce65a3",
"canvaskit/canvaskit.js.symbols": "74a84c23f5ada42fe063514c587968c6",
"canvaskit/skwasm.js": "5d4f9263ec93efeb022bb14a3881d240",
"canvaskit/chromium/canvaskit.wasm": "399e2344480862e2dfa26f12fa5891d7",
"canvaskit/chromium/canvaskit.js.symbols": "ee7e331f7f5bbf5ec937737542112372",
"canvaskit/chromium/canvaskit.js": "901bb9e28fac643b7da75ecfd3339f3f",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"canvaskit/canvaskit.js": "738255d00768497e86aa4ca510cce1e1",
"canvaskit/skwasm.wasm": "4051bfc27ba29bf420d17aa0c3a98bce",
"flutter_bootstrap.js": "ec2fcd85a1b7b87925adaa8e4cd02fdc",
"manifest.json": "f0a87ef99757fbe4b0bef97163defc8f",
"main.dart.js": "7d8ac9bbac6761f85c16772aaa326e67"};
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
