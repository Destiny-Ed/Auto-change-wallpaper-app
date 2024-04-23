import 'package:flutter/foundation.dart';

void appLogger(dynamic s) {
  if (kDebugMode) {
    print(s);
  }
}
