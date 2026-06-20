// GENERATED-STUB: substitua este arquivo executando `flutterfire configure`
// (CLI FlutterFire) apos criar o projeto no Firebase. Os valores abaixo sao
// apenas marcadores para o codigo compilar antes da configuracao real.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'SUBSTITUIR',
    appId: 'SUBSTITUIR',
    messagingSenderId: 'SUBSTITUIR',
    projectId: 'SUBSTITUIR',
    storageBucket: 'SUBSTITUIR.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'SUBSTITUIR',
    appId: 'SUBSTITUIR',
    messagingSenderId: 'SUBSTITUIR',
    projectId: 'SUBSTITUIR',
    storageBucket: 'SUBSTITUIR.appspot.com',
    iosBundleId: 'br.edu.ifal.cuidabem',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'SUBSTITUIR',
    appId: 'SUBSTITUIR',
    messagingSenderId: 'SUBSTITUIR',
    projectId: 'SUBSTITUIR',
    storageBucket: 'SUBSTITUIR.appspot.com',
    authDomain: 'SUBSTITUIR.firebaseapp.com',
  );
}
