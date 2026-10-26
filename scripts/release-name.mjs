// מספר הגרסה, זמן העדכון ושם קובץ להורדה עם הגרסה, התאריך והשעה (שעון ישראל), למשל: lo-lishkoach-v1.5-26.10.2026-10.20.apk
// הזמן הוא זמן העדכון בקוד (ה-commit), כך שהאתר, הקובץ לטלפון ודף המידע מציגים בדיוק אותו זמן.
// שימוש: node scripts/release-name.mjs [קידומת] [סיומת]   |   node scripts/release-name.mjs --code (מספר גרסה פנימי לאנדרואיד)
import { readFileSync } from 'node:fs';
import { execSync } from 'node:child_process';
import { fileURLToPath, pathToFileURL } from 'node:url';

// הגרסה כתובה בראש הקוד של האפליקציה: const APP_VERSION = '1.5'
export function appVersion() {
  const html = readFileSync(new URL('../www/index.html', import.meta.url), 'utf8');
  return html.match(/const APP_VERSION = '([^']+)'/)?.[1] || '0';
}
// 1.5 → 105: מספר שעולה בכל גרסה, כדי שהטלפון יתקין מעל הגרסה הקודמת
export function versionCode() {
  const [major = 0, minor = 0] = appVersion().split('.').map(Number);
  return major * 100 + minor;
}
export function commitTime() {
  try { return execSync('git log -1 --format=%cI', { encoding: 'utf8', cwd: fileURLToPath(new URL('..', import.meta.url)), stdio: ['ignore', 'pipe', 'ignore'] }).trim() || new Date().toISOString(); } catch { return new Date().toISOString(); }
}
// 26.10.2026-10.20 (אותו חישוב בדיוק נמצא גם בדף www/info/index.html)
export function stamp(iso) {
  const p = Object.fromEntries(new Intl.DateTimeFormat('en-GB', { timeZone: 'Asia/Jerusalem', day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit', hourCycle: 'h23' })
    .formatToParts(new Date(iso)).map((x) => [x.type, x.value]));
  return `${p.day}.${p.month}.${p.year}-${p.hour}.${p.minute}`;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  if (process.argv[2] === '--code') console.log(versionCode());
  else if (process.argv[2] === '--version') console.log(appVersion());
  else {
    const [prefix = 'lo-lishkoach', ext = 'apk'] = process.argv.slice(2);
    console.log(`${prefix}-v${appVersion()}-${stamp(commitTime())}.${ext}`);
  }
}
