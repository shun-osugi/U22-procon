import 'package:envied/envied.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'env/env.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get web {
    return FirebaseOptions(
      apiKey: 'Env.key',
      appId: '1:184050155801:web:f4bfdb1c8374db126e4588',
      messagingSenderId: '184050155801',
      projectId: 'u22procon-bc3be',
      authDomain: 'u22procon-bc3be.firebaseapp.com',
      storageBucket: 'u22procon-bc3be.appspot.com',
    );
  }

  static FirebaseOptions get android {
    return FirebaseOptions(
      apiKey: 'Env.key',
      appId: '1:184050155801:android:94289f8834387ef16e4588',
      messagingSenderId: '184050155801',
      projectId: 'u22procon-bc3be',
      storageBucket: 'u22procon-bc3be.appspot.com',
    );
  }

  static FirebaseOptions get ios {
    return FirebaseOptions(
      apiKey: 'Env.key',
      appId: '1:184050155801:ios:20d82c10d7d042996e4588',
      messagingSenderId: '184050155801',
      projectId: 'u22procon-bc3be',
      storageBucket: 'u22procon-bc3be.appspot.com',
      iosBundleId: 'com.example.u22Procon',
    );
  }
}
