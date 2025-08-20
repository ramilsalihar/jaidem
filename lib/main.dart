import 'package:flutter/material.dart';
import 'package:jaidem/core/data/injection.dart';
import 'core/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initInjections();

  runApp(const App());
}
