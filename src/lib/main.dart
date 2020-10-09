import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';
import 'package:kudosapp/kudos_app.dart';
import 'package:kudosapp/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  setupLocator();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  runApp(KudosApp());
}
