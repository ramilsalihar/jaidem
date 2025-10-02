import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/features/menu/data/datasources/menu_remote_datasource_impl.dart';
import 'package:jaidem/firebase_options.dart';
import 'core/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initInjections();
  final ds = MenuRemoteDatasourceImpl(sl<FirebaseFirestore>());

  // Add dummy data
  await ds.seedDummyData();

  runApp(const App());
}
