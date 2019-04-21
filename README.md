# FCPS SIS GradeView
[![Travis Build Status](https://api.travis-ci.org/sumanthratna/grade_view.svg?branch=master)](https://travis-ci.org/sumanthratna/grade_view) [![Codemagic Build Status](https://api.codemagic.io/apps/5cbcc27533718337908b8cc2/5cbcc27533718337908b8cc1/status_badge.svg)](https://codemagic.io/apps/5cbcc27533718337908b8cc2/5cbcc27533718337908b8cc1/latest_build) [![Bitrise Build Status](https://app.bitrise.io/app/1eb88e8e2f886294/status.svg?token=dbUXfDkBiOLZlYKQiZTgZA&branch=master)](https://app.bitrise.io/app/1eb88e8e2f886294) [![Cirrus-CI Build Status](https://api.cirrus-ci.com/github/sumanthratna/grade_view.svg)](https://cirrus-ci.com/github/sumanthratna/grade_view)


An app for FCPS SIS.

## Setup
The app uses [Flutter](https://flutter.dev), so you should install it. Then `cd` into `grade_view` and run `flutter run`. You should have a simulator/emulator running or a physical device connected. More information is available at [Flutter's GitHub repository](https://github.com/flutter/flutter) and [their website](https://flutter.dev/).

### iOS
Before running `flutter run` you should copy `ios/Runner/GoogleService-Info-sample.plist` to `ios/Runner/GoogleService-Info.plist`. Then edit the new file and under the key `API_KEY` enter the Firebase API key (you will likely not have access to this). Here's a simple script (I use `zsh` on a Mac so instead of `response=$response:l` you'll need to use the correct command):
```bash
source path/to/grade_view/SECRETS.bat
cp path/to/grade_view/ios/Runner/GoogleService-Info-sample.plist path/to/grade_view/ios/Runner/GoogleService-Info.plist
plutil -replace API_KEY -string "$FIREBASE_SECRET" grade_view/ios/Runner/GoogleService-Info.plist
```
If you use the above script, you should create a file `SECRETS.bat` inside of `grade_view` that looks like:
```bash
FIREBASE_SECRET="MyFireba5eK3y"
```
Once again, you shouldn't have access to the correct value of `MyFireba5eK3y`.

### Android
[THIS SECTION IS INCOMPLETE]

If you don't have a keystore, create one with `keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key`. Then create `grade_view/android/key.properties` with the following contents:
```
storePassword=<password from previous step>
keyPassword=<password from previous step>
keyAlias=key
storeFile=</Users/<user name>/key.jks>
```

## Usage
Run the app and enter either your FCPS credentials or the test user credentials. The test user's username is `1234567`. The password field can be left empty (the password does not matter for the test user).
