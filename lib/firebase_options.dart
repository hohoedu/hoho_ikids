// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA1RCdFbeYBOUwYgGFxYBW8276MzipJZCU',
    appId: '1:1007510164604:web:8ce0dc690376342e4565f9',
    messagingSenderId: '1007510164604',
    projectId: 'hanibooki',
    authDomain: 'hanibooki.firebaseapp.com',
    storageBucket: 'hanibooki.firebasestorage.app',
    measurementId: 'G-BM42B7QL87',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBglW_E953ZmoubEJr85z2sg-lTgcLk7Nc',
    appId: '1:1007510164604:android:35e4d9ed78ada02c4565f9',
    messagingSenderId: '1007510164604',
    projectId: 'hanibooki',
    storageBucket: 'hanibooki.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDRHmjWiFoqzHvsU6lg13LGKOxFH7CxHTc',
    appId: '1:1007510164604:ios:ff161944dbdc318e4565f9',
    messagingSenderId: '1007510164604',
    projectId: 'hanibooki',
    storageBucket: 'hanibooki.firebasestorage.app',
    iosBundleId: 'com.hohoedu.haniBooki',
  );
}
