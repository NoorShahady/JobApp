import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:first_version/screens/SignInScreen.dart';
import 'package:first_version/theme/app_theme.dart';
import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}



class MyApp extends StatelessWidget {



  const MyApp({super.key});
  //
  // get uti => null;
  //
  // get context => null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HireMe',
      // theme: AppTheme.light(),
      // darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const SignInScreen(),

    );
  }
}
