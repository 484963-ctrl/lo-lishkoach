// רץ בכל עדכון של האתר ובכל בנייה של הקובץ לטלפון: כותב את מספר הגרסה ואת זמן העדכון לקובץ www/version.json.
// דף המידע ומסך ההגדרות מציגים אותם.
import { writeFileSync } from 'node:fs';
import { execSync } from 'node:child_process';
import { appVersion, commitTime } from './release-name.mjs';

let commit = process.env.GITHUB_SHA || '';
try { commit ||= execSync('git rev-parse HEAD', { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }).trim(); } catch {}
const info = { version: appVersion(), updatedAt: commitTime(), commit: commit.slice(0, 7) };
writeFileSync(new URL('../www/version.json', import.meta.url), JSON.stringify(info) + '\n');
console.log('version.json', info);
