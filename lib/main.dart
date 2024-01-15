import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uascapstone/dashboard/DasboardPage.dart';
import 'package:uascapstone/dashboard/LoginPage.dart';
import 'package:uascapstone/dashboard/RegisterPage.dart';
import 'package:uascapstone/dashboard/SplashPage.dart';
import 'package:uascapstone/firebase_options.dart';
import 'package:uascapstone/support/AddFormPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    title: 'Aplikasi Keuangan',
    initialRoute: '/',
    routes: {
      '/': (context) => const SplashPage(),
      '/login': (context) => LoginPage(),
      '/register': (context) => const RegisterPage(),
      '/dashboard': (context) => const DashboardPage(),
      '/add': (context) => AddFormPage(),
      //'/detail': (context) => DetailPage(),
    },
  ));
}
