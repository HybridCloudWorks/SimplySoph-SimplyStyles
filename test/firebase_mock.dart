import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void setupFirebaseCoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodCodec codec = StandardMethodCodec();

  TestWidgetsFlutterBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
    'plugins.flutter.io/firebase_core',
    (ByteData? message) async {
      final MethodCall call = codec.decodeMethodCall(message!);
      if (call.method == 'Firebase#initializeCore') {
        return codec.encodeSuccessEnvelope([
          {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': '123',
              'appId': '1:1234567890:web:abc',
              'messagingSenderId': '1234567890',
              'projectId': 'test-project',
            },
            'pluginConstants': {},
          }
        ]);
      }
       if (call.method == 'Firebase#app') {
        return codec.encodeSuccessEnvelope({
          'name': '[DEFAULT]',
          'options': {
            'apiKey': '123',
            'appId': '1:1234567890:web:abc',
            'messagingSenderId': '1234567890',
            'projectId': 'test-project',
          },
          'pluginConstants': {},
        });
      }
      return null;
    },
  );
}
