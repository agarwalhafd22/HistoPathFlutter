'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "31697a66e514216efacc2beaec113503",
"assets/AssetManifest.bin.json": "3e4c90d380a08d225920e62462fc2560",
"assets/AssetManifest.json": "c74aff1254bf479157651ecf21103bfd",
"assets/assets/images/appendix.jpeg": "9563d32184ef32809a924f6a78c1f3bf",
"assets/assets/images/appendixhanddrawn.jpg": "8b1f9b7c8548dc4c905402b6cbbb4dad",
"assets/assets/images/appendixhanddrawn2.jpg": "7bb1421e406467f5c306a908e1b38642",
"assets/assets/images/breast.jpg": "05fe7fcbeecd9adf2727bdfe8e2be86b",
"assets/assets/images/colon.jpg": "394d1b97f0d67f414ade5163b11d8ede",
"assets/assets/images/compact_bone.png": "23e01ed0102ebfe056bba2f88f6fceb7",
"assets/assets/images/endocrine.png": "c3579edc0bd8fae11fc7de2d1b5ee86f",
"assets/assets/images/femalers.png": "23520053bef20364ddb46fa841b7d187",
"assets/assets/images/gastroint.png": "299f2a2e5400b8777c27081d0c5193de",
"assets/assets/images/integumentary.png": "03245e1146eadfdf84ade6bf4e2d2067",
"assets/assets/images/kidney.jpg": "015e34427e0ccc940b25e0a6eb82eaaa",
"assets/assets/images/largeintestine.jpg": "c56babaf0486b0854f33d46983a9ef00",
"assets/assets/images/largeintestinehanddrawn.jpg": "a5a2cda5bb08ae7070b709b0d65064d5",
"assets/assets/images/largeintestinehanddrawn2.jpg": "fb012478b590f92ab2574d5206e9daa5",
"assets/assets/images/large_size_artery.jpg": "3ddd8dc85d21c07cadc47b927e1e1b66",
"assets/assets/images/liver.jpg": "3440b36a631e70a4837cc03d538768aa",
"assets/assets/images/liverhanddrawn.jpg": "8b2e44cb32fe919544c4cc6074ee4f22",
"assets/assets/images/liverhanddrawn2.jpg": "3f569da23a379f8036dafb906fc42fee",
"assets/assets/images/lymphatic.png": "7001b9dd1d75cc5bc3a196f095cc6b39",
"assets/assets/images/lymph_node.jpg": "af639e12e56999fa968002b4635a458e",
"assets/assets/images/malers.png": "a138a8e56bc969c21592582869ee504f",
"assets/assets/images/medium_sized_artery.jpg": "ca18b542c578ead15c3356430a6ff41a",
"assets/assets/images/nervous.png": "ff47a34f3dff3d22c2234688ba05e1ea",
"assets/assets/images/prostate.jpeg": "cacf1b719e4154c2a4f0860de17e2977",
"assets/assets/images/renalbg.png": "48cbd57fcfc50082cc5e272b3850b5a7",
"assets/assets/images/respiratorybg.png": "89c47f534c47b96d34f1801583650288",
"assets/assets/images/skeletal.png": "b951fabe183a03fa1a4f8d0e2e902398",
"assets/assets/images/studentlogin.png": "e33b00108ecf4bd109408c7e1820438b",
"assets/assets/images/teacherlogin.png": "bab59b11f160bb8a45ba31c1bc318cbf",
"assets/assets/images/testis.jpg": "cf3318aba41653f0259b9c6bc5c4471e",
"assets/assets/images/thickskin.jpg": "cca9eda8de671c0daa2b4468a9280fee",
"assets/assets/images/thinskin.jpg": "9d7439b21455c90daae7aa3daa7a06be",
"assets/assets/images/thyroid.png": "256a30a47ce8c3e0f5c8e00a61df6f14",
"assets/assets/images/ureter.jpg": "9a08452bd743b454cd2f6057b0afeb62",
"assets/assets/images/uterus.jpg": "14f27c27a5ffb17038a46fffe4295b76",
"assets/assets/images/uterus_quiz_1.png": "6de7bb12095738412da4fc1727df6ec3",
"assets/assets/images/uterus_quiz_2.png": "ecb2f3462dba6c1eb1aea2e51949b22e",
"assets/assets/images/uterus_quiz_3.png": "160c74e6011b6b4b58be585a3fd2b662",
"assets/assets/images/vascular.png": "f5db4eb3262f7eeed9e14a081840114c",
"assets/assets/images/whitebg.png": "f01b5a45ca0aae08e2676fb25cbe4610",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "0cea562f0ae5d359226a45dc393ef14d",
"assets/NOTICES": "cb13cfc01649880a9e6d820468a3c59f",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "738255d00768497e86aa4ca510cce1e1",
"canvaskit/canvaskit.js.symbols": "74a84c23f5ada42fe063514c587968c6",
"canvaskit/canvaskit.wasm": "9251bb81ae8464c4df3b072f84aa969b",
"canvaskit/chromium/canvaskit.js": "901bb9e28fac643b7da75ecfd3339f3f",
"canvaskit/chromium/canvaskit.js.symbols": "ee7e331f7f5bbf5ec937737542112372",
"canvaskit/chromium/canvaskit.wasm": "399e2344480862e2dfa26f12fa5891d7",
"canvaskit/skwasm.js": "5d4f9263ec93efeb022bb14a3881d240",
"canvaskit/skwasm.js.symbols": "c3c05bd50bdf59da8626bbe446ce65a3",
"canvaskit/skwasm.wasm": "4051bfc27ba29bf420d17aa0c3a98bce",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "383e55f7f3cce5be08fcf1f3881f585c",
"flutter_bootstrap.js": "b4bb5dce58d9bd82d251fe6899160b66",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "dea39e08228eef12a11c0830cbb4254d",
"/": "dea39e08228eef12a11c0830cbb4254d",
"main.dart.js": "9b15258918812305ed9a4e9f29059373",
"manifest.json": "08f790c1849e33644e35870c5167363c",
"version.json": "a2295b1f5e15e894820c32a10ef4d5e6"};
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
