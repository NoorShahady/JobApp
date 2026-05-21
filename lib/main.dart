import 'package:firebase_core/firebase_core.dart';
import 'package:first_version/Models/jobs_store.dart';
import 'package:first_version/screens/SignInScreen.dart';
import 'package:first_version/theme/app_theme.dart';
import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  JobsStore.instance.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HireMe',
      theme: AppTheme.light(),
      themeMode: ThemeMode.system,
      home: const SignInScreen(),
    );
  }
}
