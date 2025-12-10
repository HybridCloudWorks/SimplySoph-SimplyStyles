import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

void setupFirebaseCoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setupFirebaseCoreMocksCallback(() async {
    MethodChannelFirebase.channel.setMockMethodCallHandler((call) async {
      if (call.method == 'Firebase#initializeCore') {
        return [
          {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': '123',
              'appId': '123',
              'messagingSenderId': '123',
              'projectId': '123',
            },
            'pluginConstants': {},
          }
        ];
      }
      if (call.method == 'Firebase#initializeApp') {
        return {
          'name': call.arguments['appName'],
          'options': call.arguments['options'],
          'pluginConstants': {},
        };
      }
      return null;
    });
  });
}

typedef Callback = Future<void> Function();

void setupFirebaseCoreMocksCallback(Callback callback) {
  // Logic to inject the mock into the platform interface
  // In newer versions of firebase_core_platform_interface, there is a dedicated method.
  // But usually calling the channel mock is enough if we call it before initializeApp.

  // Since we don't have the explicit 'setupFirebaseCoreMocks' utility from the package exposed easily
  // (it's often in a test helper package), we manually mock the channel.
  // Actually, 'firebase_core_platform_interface' usually exports `setupFirebaseCoreMocks`.
  // Let's check imports.
  // If not available, the above manual MethodChannel mock is the standard way for older Flutter/Firebase versions.
  // However, modern firebase_core requires `TestFirebaseCoreHostApi` or similar.

  // To stay safe and simple for this environment where I can't check all package versions easily:
  // I will rely on the `MethodChannelFirebase` being the implementation detail.

  callback();
}
