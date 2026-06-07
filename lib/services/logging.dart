import 'package:flutter/foundation.dart';

void logError(String source, Object error, [StackTrace? stack]) {
  debugPrint('$source error: $error');
  if (stack != null) {
    debugPrint('$source stack: $stack');
  }
}
