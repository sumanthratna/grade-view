# FCPS SIS GradeView
[![Codemagic build status](https://api.codemagic.io/apps/5c699bc024cab100120d2931/5c699bc024cab100120d2930/status_badge.svg)](https://codemagic.io/apps/5c699bc024cab100120d2931/5c699bc024cab100120d2930/latest_build) [![Travis Build Status](https://travis-ci.org/sumanthratna/grade-view.svg?branch=master)](https://travis-ci.org/sumanthratna/grade-view)

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
 - [x] quarters during grade-fetching is hard-coded to `third_quarter`, fix this (get first element in `dynamic`)
 - [x] noInternet snackbar is being triggered even if login is successful
 - [x] some assignment names are too long for cards in Course view
 - [ ] show teacher email next to course id/name, open mail app on click
 - [x] fix padding
 - [x] add widget testing
 - [ ] add integration tests
 - [ ] add bitrise integration
 - [ ] implement push notifications
 - [ ] create graphs of grades over time
 - [x] don't store password longer than it needs to be stored
 - [ ] add screenshots to README
 - [ ] implement methods for all API classes
 - [x] make `Breakdown` class extend `List<Weighting>`
 - [ ] don't send username and password to API call methods as arguments
 - [x] double clicking login button causes courses to show up twice
 - [x] allow swiping in `HomePage` (use `TabBar`?)
 - [x] fix `DataTable` on small devices
 - [x] `IntrinsicHeight` is expensive (`O(n^2)`)
 - [ ] use BLoC pattern
 - [ ] snackbar tests show `status code 400`
 - [ ] add CirrusCI
 - [ ] `DataTable` is expensive
 - [x] remove `backButton` from `CoursePage` and `AssignmentPage` and instead use an `AppBar` (similar to the `AppBar` in `HomePage`)
 - [x] split contents of `_tabs` in `HomePage` into multiple `StatelessWidget`s
 - [ ] adding `Assignment`s to the front of a `List` is costly for large `List`s
