# FCPS SIS GradeView
[![Travis Build Status](https://travis-ci.org/sumanthratna/grade-view.svg?branch=master)](https://travis-ci.org/sumanthratna/grade-view) [![Codemagic Build Status](https://api.codemagic.io/apps/5c699bc024cab100120d2931/5c699bc024cab100120d2930/status_badge.svg)](https://codemagic.io/apps/5c699bc024cab100120d2931/5c699bc024cab100120d2930/latest_build) [![Bitrise Build Status](https://app.bitrise.io/app/1eb88e8e2f886294/status.svg?token=dbUXfDkBiOLZlYKQiZTgZA&branch=master)](https://app.bitrise.io/app/1eb88e8e2f886294) [![Cirrus-CI Build Status](https://api.cirrus-ci.com/github/sumanthratna/grade-view.svg)](https://cirrus-ci.com/github/sumanthratna/grade-view)


An app for FCPS SIS.

## Setup
The app uses [Flutter](https://flutter.dev), so you should install it. Then `cd` into `grade-view` and run `flutter run`. You should have a simulator/emulator running or a physical device connected. More information is available at [Flutter's GitHub repo](https://github.com/flutter/flutter) and their website.

Before running `flutter run` you should copy `ios/Runner/GoogleService-Info-sample.plist` to `ios/Runner/GoogleService-Info.plist`. Then edit the new file and under the key `API_KEY` enter the Firebase API key (you will likely not have access to this). I use [OnDir](https://github.com/alecthomas/ondir), so in my `.ondirrc` file I have (I also use `zsh` on a Mac so instead of `response=$response:l` you'll need to use the correct command and instead of `open -a Simulator` you'll need the correct command):
```bash
enter path/to/grade-view
    find . -name '.DS_Store' -type f -delete
    read "response?Run app in Simulator? [y/N] "
    response=$response:l #to lower case
    source path/to/grade-view/FIREBASE_SECRET.bat
    cp path/to/grade-view/ios/Runner/GoogleService-Info-sample.plist path/to/grade-view/ios/Runner/GoogleService-Info.plist
    plutil -replace API_KEY -string "$FIREBASE_SECRET" grade-view/ios/Runner/GoogleService-Info.plist
    if [[ "$response" =~ ^(yes|y)$ ]]
    then
      open -a Simulator
      flutter run
    fi

final leave path/to/grade-view
    rm path/to/grade-view/ios/Runner/GoogleService-Info.plist
```
If you use the above `ondir` script, you should create a file `FIREBASE_SECRET.bat` inside of `grade-view` that looks like:
```bash
FIREBASE_SECRET="MyFireba5eK3y"
```
Once again, you shouldn't have access to the correct value of `MyFireba5eK3y`.

## Usage
Run the app and enter either your FCPS credentials or the test user credentials. The test user's username is `1234567`. The password field can be left empty (the password does not matter for the test user).

## To-Do List:
Not necessarily in order of priority.
 - [ ] show teacher email next to course id/name, open mail app on click
 - [ ] add integration tests
 - [ ] implement push notifications
 - [ ] create graphs of grades over time
 - [ ] implement methods for all API classes
 - [ ] don't send username and password to API call methods as arguments
 - [ ] use BLoC pattern
 - [ ] snackbar tests show `status code 400`
 - [ ] `DataTable` is expensive
 - [ ] adding `Assignment`s to the front of a `List` is costly for large `List`s
 - [ ] allow adding grades even if there's no breakdown information (all assignments are weighted equally)
 - [x] allow editing of artificial assignments
 - [ ] only show assignments that are of a certain type when that type is clicked in the breakdown `DataTable`
 - [ ] `RenderFlex` exception when selecting date in add grade form
 - [ ] convert all `double` operations to use the `Decimal` package
 - [ ] selecting item from dropdown requires two clicks (focusing issue)
 - [ ] some properties don't immediately change when editing assignments (dropdown)
