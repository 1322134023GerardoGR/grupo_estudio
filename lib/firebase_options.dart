import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está definido para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDnIF15_0s-25MtLYxY3wC3paHZBsdqMf0',
    appId: '1:959260074803:web:cf8b466900bebd288a5446',
    messagingSenderId: '959260074803',
    projectId: 'grupo-eff55',
    authDomain: 'grupo-eff55.firebaseapp.com',
    storageBucket: 'grupo-eff55.firebasestorage.app',
    measurementId: "G-53L6KLC8JB",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'TU_ANDROID_API_KEY',
    appId: '1:959260074803:android:9c6ef584d416b3198a5446',
    messagingSenderId: 'TU_ANDROID_MESSAGING_SENDER_ID',
    projectId: 'TU_PROYECTO_ID',
    storageBucket: 'TU_ANDROID_STORAGE_BUCKET',
  );

}