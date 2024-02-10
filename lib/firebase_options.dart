// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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
    apiKey: 'AIzaSyClBTadmQ2RE-tjORHKe7vOwG9_TSKOOWs',
    appId: '1:281552032701:android:8405301e5dad18bdc6b8d4',
    messagingSenderId: '281552032701',
    projectId: 'b-iot-fb63c',
    databaseURL: 'https://b-iot-fb63c-default-rtdb.firebaseio.com',
    storageBucket: 'b-iot-fb63c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC5WETiC6Mk38oTQxeeVrgiwUlxmbZEFJM',
    appId: '1:281552032701:ios:77957efc1a78f77dc6b8d4',
    messagingSenderId: '281552032701',
    projectId: 'b-iot-fb63c',
    databaseURL: 'https://b-iot-fb63c-default-rtdb.firebaseio.com',
    storageBucket: 'b-iot-fb63c.appspot.com',
    iosBundleId: 'com.example.uiBiot',
  );
}
