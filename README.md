# FCPS SIS GradeView
[![Codemagic build status](https://api.codemagic.io/apps/5c699bc024cab100120d2931/5c699bc024cab100120d2930/status_badge.svg)](https://codemagic.io/apps/5c699bc024cab100120d2931/5c699bc024cab100120d2930/latest_build) [![Travis Build Status](https://travis-ci.org/sumanthratna/grade-view.svg?branch=master)](https://travis-ci.org/sumanthratna/grade-view)

An app for FCPS SIS.

## Setup
The app uses [Flutter](https://github.com/flutter/flutter), so you should install it. Then `cd` into `grade-view` and run `flutter run`. You should have a simulator/emulator running or a physical device connected. More information is available at Flutter's GitHub repo and their website.

Before running `flutter run` you should copy `ios/Runner/GoogleService-Info-sample.plist` to `ios/Runner/GoogleService-Info.plist`. Then edit the new file and under the key `API_KEY` enter the Firebase API key (you will likely not have access to this). I use [OnDir](https://github.com/alecthomas/ondir), so in my `.ondirrc` file I have (I also use `zsh` on a Mac so instead of `response=$response:l` you'll need to use the correct command and instead of `open -a Simulator` you'll need the correct command):
```bash
enter /Users/suman/quantum/grade-view
    find . -name '.DS_Store' -type f -delete
    read "response?Run app in Simulator? [y/N] "
    response=$response:l #to lower case
    source path/to/grade-view/FIREBASE_SECRET.bat
    cp path/to/grade-view/ios/Runner/GoogleService-Info-sample.plist ~/quantum/grade-view/ios/Runner/GoogleService-Info.plist
    plutil -replace API_KEY -string "$FIREBASE_SECRET" path/to/grade-view/ios/Runner/GoogleService-Info.plist
    if [[ "$response" =~ ^(yes|y)$ ]]
    then
      open -a Simulator
      flutter run
    fi

final leave path/to//grade-view
    rm path/to/grade-view/ios/Runner/GoogleService-Info.plist

```
If you use the above `ondir` script, you should create a file `FIREBASE_SECRET.bat` inside of `grade-view` that looks like:
```bash
FIREBASE_SECRET=MyFireba5eK3y
```
Once again, you shouldn't have access to the correct value of `MyFireba5eK3y`.

## To-Do List:
 - [x] quarters during grade-fetching is hard-coded to `third_quarter`, fix this to be generic (get first element in dynamic)
 - [x] noInternet snackbar is being triggered even if login is successful
 - [x] some assignment names are too long for cards in Course view
 - [ ] show teacher email next to course id/name, open mail app on click
 - [x] fix padding
 - [x] add widget testing
 - [ ] add integration tests
 - [ ] add bitrise integration
 - [ ] implement push notifications
 - [ ] cache grades and create graphs of grades over time
 - [x] don't store password longer than it needs to be stored
 - [ ] add screenshots to README
 - [ ] implement methods for all API classes
 - [x] make `Breakdown` class extend `List<Weighting>` instead of 'having' one
 - [ ] don't send username and password to API call methods as arguments
 - [x] double clicking login button causes courses to show up twice
 - [x] allow swiping in `HomePage` (use `TabBar`?)
 - [ ] fix `DataTable` on small devices
 - [ ] make `getUser` and `getGrades` methods in `API` return `Future<bool>`
 - [ ] `IntrinsicHeight` in `build` in forms in `lib/course_page.dart` is expensive (`O(n^2)`)
 - [ ] before gradebook closes for quarter ending, fetch grades
 - [ ] use BLoC pattern
 - [ ] snackbar tests show `status code 400` but all tests pass (bug?)
