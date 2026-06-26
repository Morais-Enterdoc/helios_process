import 'package:flutter/material.dart';
import 'app.dart';
import 'core/database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppDatabase.init();

  runApp(const HeliosProcessApp());
}