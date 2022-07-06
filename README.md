# glog

glog is a dart implementation of the google's
[glog](https://github.com/google/glog) format.

## Getting started

Add the dependency:

```
$ dart pub add glog
```

## Usage

```dart
// initialize the logger at the module's boundary:

import 'package:glog/glog.dart';
const logger = GlogContext('ui');

// then use it later

logger.info('Hello, world!');
```
