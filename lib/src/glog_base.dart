// Copyright 2022 Vladimir Pouzanov <farcaller@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:isolate';
import 'dart:io' show Platform, stderr;
// import 'dart:developer' as developer;

import 'package:date_format/date_format.dart';
import 'package:stack_trace/stack_trace.dart';

enum LogLevel {
  trace,
  debug,
  info,
  warning,
  error,
  fatal,
}

extension ParseToString on LogLevel {
  String toShortString() {
    switch (this) {
      case LogLevel.trace:
        return 'T';
      case LogLevel.debug:
        return 'D';
      case LogLevel.info:
        return 'I';
      case LogLevel.warning:
        return 'W';
      case LogLevel.error:
        return 'E';
      case LogLevel.fatal:
        return 'F';
      default:
        return '?';
    }
  }

  int toLoggingLevel() {
    switch (this) {
      case LogLevel.trace:
        return 300;
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.fatal:
        return 1200;
      default:
        return 800;
    }
  }
}

class GlogLogger {
  final Set<String> mutedContexts = {};
  final Set<String> soloedContexts = {};

  static final GlogLogger _globalLogger = GlogLogger();

  static GlogLogger get global => _globalLogger;

  log(LogLevel level, String context, String msg) {
    if (soloedContexts.isNotEmpty && !soloedContexts.contains(context)) return;
    if (mutedContexts.contains(context)) return;

    final date = formatDate(
        DateTime.now(), [mm, dd, ' ', HH, ':', nn, ':', ss, '.', uuu]);
    final frame = Trace.from(StackTrace.current).terse.frames[2];
    var fileName = frame.library.split('/').last;
    if (Platform.isWindows) {
      fileName = fileName.split('\\').last;
    }

    final formattedMessage =
        '${level.toShortString()}$date ${Isolate.current.debugName} $fileName:${frame.line}] $msg\n';

    // TODO: add an option to pick and choose
    // developer.log(formattedMessage, level: level.toLoggingLevel());
    stderr.write(formattedMessage);
  }
}

class GlogContext {
  final String _context;

  const GlogContext(this._context);

  void trace(String msg) =>
      GlogLogger._globalLogger.log(LogLevel.trace, _context, msg);

  void debug(String msg) =>
      GlogLogger._globalLogger.log(LogLevel.debug, _context, msg);

  void info(String msg) =>
      GlogLogger._globalLogger.log(LogLevel.info, _context, msg);

  void warning(String msg) =>
      GlogLogger._globalLogger.log(LogLevel.warning, _context, msg);

  void error(String msg) =>
      GlogLogger._globalLogger.log(LogLevel.error, _context, msg);

  void fatal(String msg) =>
      GlogLogger._globalLogger.log(LogLevel.fatal, _context, msg);
}
