#!/usr/bin/env bash
# בונה את האפליקציה לאנדרואיד: lo-lishkoach.apk בתיקייה הראשית.
# דרישות: Node 22, Java 21 ו-Android SDK. בבנייה האוטומטית ב-GitHub הכול מותקן לבד.
set -euo pipefail
cd "$(dirname "$0")/.."

[ -d node_modules ] || npm ci
rm -rf android
npx cap add android
npx cap sync android
MAIN=android/app/src/main

# מספר גרסה עולה בכל בנייה, כדי שהטלפון יתקין מעל הגרסה הקודמת
CODE="${VERSION_CODE:-1}"
sed -i "s/versionCode .*/versionCode $CODE/; s/versionName .*/versionName \"1.$CODE\"/" android/app/build.gradle

# הרשאות: התראות (אנדרואיד 13 ומעלה), בזמן מדויק, וגם אחרי הפעלה מחדש של הטלפון
sed -i 's#<uses-permission android:name="android.permission.INTERNET" />#&\n    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />\n    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />\n    <uses-permission android:name="android.permission.USE_EXACT_ALARM" />\n    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" android:maxSdkVersion="32" />#' $MAIN/AndroidManifest.xml
grep -q POST_NOTIFICATIONS $MAIN/AndroidManifest.xml

# אייקון, מסך פתיחה סגול וסמל קטן להתראות
rm -rf $MAIN/res/drawable-land-* $MAIN/res/drawable-port-* $MAIN/res/drawable/splash.png
cp -r android-res/res/. $MAIN/res/

# חתימה קבועה (debug.keystore), כדי שגרסה חדשה תותקן מעל הקודמת בלי למחוק נתונים
mkdir -p ~/.android && cp debug.keystore ~/.android/debug.keystore

(cd android && chmod +x gradlew && ./gradlew assembleDebug)
cp android/app/build/outputs/apk/debug/app-debug.apk lo-lishkoach.apk
echo "נבנה: lo-lishkoach.apk"
