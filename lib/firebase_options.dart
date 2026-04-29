import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBmj0FGo4CoJA8b0PV7LYRqUzN9ymj9dB8',
    appId: '1:953091025079:android:56b8a3bc9acbe0a4514532',
    messagingSenderId: '953091025079',
    projectId: 'thproject-fdef3',
    storageBucket: 'thproject-fdef3.firebasestorage.app',
  );
}
