import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Hive for local storage
    await Hive.initFlutter();
    await Hive.openBox('settings');
    await Hive.openBox('user_cache');

    // Initialize dependency injection
    await di.init();

    // Lock to portrait mode
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    runApp(const ChatApp());
  } catch (e, stackTrace) {
    debugPrint('Initialization Error: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Text(
                  'حدث خطأ أثناء تشغيل التطبيق:\n\n$e\n\n$stackTrace',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
