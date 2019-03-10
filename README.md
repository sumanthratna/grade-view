# FCPS SIS GradeView
[![Codemagic build status](https://api.codemagic.io/apps/5c699bc024cab100120d2931/5c699bc024cab100120d2930/status_badge.svg)](https://codemagic.io/apps/5c699bc024cab100120d2931/5c699bc024cab100120d2930/latest_build) [![Travis Build Status](https://travis-ci.org/sumanthratna/grade-view.svg?branch=master)](https://travis-ci.org/sumanthratna/grade-view)

An app for FCPS SIS.

## To-Do List:
 - [ ] quarters during grade-fetching is hard-coded to `third_quarter`, fix this to be generic (get first element in dynamic)
 - [x] noInternet snackbar is being triggered even if login is successful
 - [x] some assignment names are too long for cards in Course view
 - [ ] show teacher email next to course id/name, open mail app on click
 - [x] fix padding
 - [x] add widget testing
 - [ ] add integration tests
 - [ ] add bitrise integration
 - [ ] implement push notifications
 - [ ] cache grades and create graphs of grades over time
 - [ ] don't store password longer than it needs to be stored
 - [ ] add screenshots to README
 - [ ] implement methods for all API classes
 - [ ] make `Breakdown` class extend `List<Weighting>` instead of 'having' one
 - [ ] don't send username and password to API call methods as arguments (create `API` object instead of calling static methods?)
 - [ ] double clicking login button causes courses to show up twice
 - [ ] allow swiping in `HomePage` (use `TabBar`?)
 - [ ] use `FutureBuilder` when retrieving courses
