# FCPS SIS GradeView

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/ad20713867594ba3a5a3a9eb2627e00a)](https://app.codacy.com/app/sumanthratna/grade_view?utm_source=github.com&utm_medium=referral&utm_content=sumanthratna/grade_view&utm_campaign=Badge_Grade_Dashboard)
[![Build Status](https://travis-ci.com/sumanthratna/grade_view.svg?branch=master)](https://travis-ci.com/sumanthratna/grade_view)

An app for FCPS SIS. [` App Store`](https://apps.apple.com/us/app/gradeview/id1459817290) [`Aptoide App Store`](https://gradeview.en.aptoide.com/)

## Setup

The app uses [Flutter](https://flutter.dev), so you should install it. Then `cd` into `grade_view` and run `flutter run`. You should have a simulator/emulator running or a physical device connected. More information is available at [Flutter's GitHub repository](https://github.com/flutter/flutter) and [their website](https://flutter.dev).

### iOS

Before running `flutter run` you should copy `ios/Runner/GoogleService-Info-sample.plist` to `ios/Runner/GoogleService-Info.plist`. Then edit the new file and under the key `API_KEY` enter the Firebase API key (you will likely not have access to this).

### Android

THIS SECTION IS INCOMPLETE

If you don't have a keystore, create one with `keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key`. Then copy `android/key.properties.sample` to `android/key.properties` and replace the appropriate values.

### macOS

Since the [`flutter_secure_storage` package](https://github.com/mogol/flutter_secure_storage) does not currently support desktop, the app does not advance beyond the login screen, although authentication functions correctly.

### Web

CORS is currently not enabled on the [unofficial SIS API](https://github.com/ovkulkarni/sis-api). As a result, authentication fails, and you will not be able to advance beyond the login page.

## Usage

Run the app and enter either your FCPS credentials or the test user credentials. The test user's username is `1234567`. The password field can be left empty (the password does not matter for the test user).
