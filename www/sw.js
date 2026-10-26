// רשת קודם, מטמון כגיבוי: המשימות נפתחות גם בלי קליטה.
const CACHE='tasks-v8',FILES=['./','index.html','manifest.webmanifest','icon.svg','config.js','fonts/rubik-hebrew-400-normal.woff2','fonts/rubik-hebrew-700-normal.woff2'];
self.addEventListener('install',e=>{self.skipWaiting();e.waitUntil(caches.open(CACHE).then(c=>c.addAll(FILES)))});
self.addEventListener('activate',e=>e.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(k=>k.startsWith('tasks-')&&k!==CACHE).map(k=>caches.delete(k)))).then(()=>self.clients.claim())));
self.addEventListener('fetch',e=>{const u=new URL(e.request.url);if(e.request.method!=='GET'||u.origin!==location.origin)return;e.respondWith(fetch(e.request).then(r=>{const copy=r.clone();caches.open(CACHE).then(c=>c.put(e.request,copy));return r}).catch(()=>caches.match(e.request,{ignoreSearch:true})))});
// לחיצה על תזכורת: חוזרים לחלון הפתוח, או פותחים אותו
self.addEventListener('notificationclick',e=>{e.notification.close();e.waitUntil(self.clients.matchAll({type:'window',includeUncontrolled:true}).then(list=>{const w=list.find(c=>new URL(c.url).pathname.startsWith(new URL('./',self.registration.scope).pathname));return w?w.focus():self.clients.openWindow('./')}))});
