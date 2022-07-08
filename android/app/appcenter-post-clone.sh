#!/usr/bin/env bash
# place this script in project/android/app/
cd ..
# fail if any command fails
set -e
# debug log
set -x

cd ..
# choose a different release channel if you want - https://github.com/flutter/flutter/wiki/Flutter-build-release-channels
# stable - recommended for production

git clone -b stable https://github.com/flutter/flutter.git
export PATH=`pwd`/flutter/bin:$PATH

flutter channel stable
flutter doctor

echo "Installed flutter to `pwd`/flutter"

# build APK
flutter build apk --release  --build-number $APPCENTER_BUILD_ID --flavor $APP_ENVIRONMENT --target=lib/main_$APP_ENVIRONMENT.dart

# if you need build bundle (AAB) in addition to your APK, uncomment line below and last line of this script.
flutter build appbundle --release --build-number $APPCENTER_BUILD_ID --flavor $APP_ENVIRONMENT --target=lib/main_$APP_ENVIRONMENT.dart

# copy the APK where AppCenter will find it
mkdir -p android/app/build/outputs/apk/$APP_ENVIRONMENT/; mv build/app/outputs/apk/$APP_ENVIRONMENT/release/app-$APP_ENVIRONMENT-release.apk $_

# copy the AAB where AppCenter will find it
mkdir -p android/app/build/outputs/bundle/${APP_ENVIRONMENT}Release/; mv build/app/outputs/bundle/${APP_ENVIRONMENT}Release/app-$APP_ENVIRONMENT-release.aab $_