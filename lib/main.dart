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
      title: 'Login App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFDC83EA), // สีหลักของแอป
          primary: const Color(0xFFDB94E6), // สีหลักที่ใช้ในส่วนต่างๆ ของแอป
          secondary: const Color(0xFFF3E5F5), // สีรองที่ใช้สำหรับเน้นส่วนต่างๆ ของแอป
        ),
        scaffoldBackgroundColor: const Color(0xFFF3E5F5),
      ),
      home: const LoginPage(), // หน้าแรก
    );
  }
}