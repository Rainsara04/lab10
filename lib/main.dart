import 'package:flutter/material.dart';
import 'package:lab10/page/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
   return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login App',

      // โทนม่วงพาสเทล
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFFF3E5F5),
        useMaterial3: true,
      ),

      home: const LoginPage(), // หน้าแรก
    );
  }
}