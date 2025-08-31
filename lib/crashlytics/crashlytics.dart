// File: lib/src/crashlytics/crashlytics.dart
import 'package:flutter/foundation.dart';

/// A simple guard function for crash reporting
Future<void> guardWithCrashlytics(VoidCallback function) async {
  if (kDebugMode) {
// In debug mode, just run the function
    function();
    return;
  }

  try {
    function();
  } catch (error, stackTrace) {
// In production, you would send this to Firebase Crashlytics
// For now, just print the error
    if (kDebugMode) {
      print('Error caught: $error');
      print('Stack trace: $stackTrace');
    }
  }
}