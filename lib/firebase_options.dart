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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCNb-GTv2lQHvLOvAkVekhv9xmjt_ZEM1g',
    appId: '1:366252616448:android:8320f6ae49bc41f714a1e5',
    messagingSenderId: '366252616448',
    projectId: 'flutterpractice-ad67b',
    storageBucket: 'flutterpractice-ad67b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAFxIg4vInIDi6cS3_KyReGDc4BZJyWHdM',
    appId: '1:366252616448:ios:8dc89fdde8b295cb14a1e5',
    messagingSenderId: '366252616448',
    projectId: 'flutterpractice-ad67b',
    storageBucket: 'flutterpractice-ad67b.firebasestorage.app',
    iosBundleId: 'com.example.practice',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDUh0Sxx1cS5o5FSYhDrJ79DApUAEdNrok',
    appId: '1:366252616448:web:b998c2f26fb6e80e14a1e5',
    messagingSenderId: '366252616448',
    projectId: 'flutterpractice-ad67b',
    authDomain: 'flutterpractice-ad67b.firebaseapp.com',
    storageBucket: 'flutterpractice-ad67b.firebasestorage.app',
  );

}