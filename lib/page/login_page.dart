import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lab10/page/show_products.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF3E5F5), //  สีพื้นหลังของหน้าเข้าสู่ระบบ
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25), // เพิ่ม padding ซ้าย-ขวา
          child: Form( // เพิ่ม Form เพื่อใช้กับ TextFormField
            key: _formKey, // เพิ่ม Form เพื่อใช้กับ TextFormField
            child: Column(
              children: [

                const SizedBox(height: 40),

                /// Logo
                const CircleAvatar(
                  radius: 45, // ขนาดของโลโก้
                  backgroundColor: Color(0xFFB155C3), // สีพื้นหลังของโลโก้
                  child: Icon(Icons.menu_book, // ใช้ไอคอนหนังสือเป็นโลโก้
                      size: 40, color: Colors.white), // สีของไอคอนโลโก้
                ),

                const SizedBox(height: 20),

                const Text(
                  "Welcome Books",
                  style: TextStyle(
                    fontSize: 36, // ขนาดของข้อความ
                    fontWeight: FontWeight.bold, // ทำให้ตัวอักษรหนาขึ้น
                    color: Color(0xFF8E6BBE), // สีของข้อความ
                  ),
                ),

                const SizedBox(height: 40), // เพิ่มระยะห่างระหว่างข้อความและฟอร์ม

                /// Card Container
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white, // สีพื้นหลังของการ์ด
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 25,
                        color: Colors.black12, // สีเงาของการ์ด
                        offset: Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    children: [

                      /// Username
                      TextFormField(
                        controller: _usernameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "กรุณากรอก username";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          hintText: "Username",
                          filled: true,
                          fillColor: const Color(0xFFF8F4FC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28), // ปรับความโค้งของขอบ
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "กรุณากรอก password";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          hintText: "Password",
                          filled: true,
                          fillColor: const Color(0xFFF8F4FC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// Login Button (logic เดิม)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB155C3),
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(18),
                            ),
                            elevation: 8,
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {

                              var json = jsonEncode({
                                "username":_usernameController.text,
                                "password":_passwordController.text,
                              });

                              var url = Uri.parse(
                                  "http://10.0.2.2:3000/api/auth/login");

                              var response = await http.post(
                                url,
                                body: json,
                                headers: {
                                  HttpHeaders.contentTypeHeader:
                                      "application/json"
                                },
                              );

                              if (response.statusCode == 200) {
                                SharedPreferences prefs =
                                    await SharedPreferences
                                        .getInstance();
                                var userjson =
                                    jsonDecode(response.body)
                                        ['payload'];
                                var tokenjson =
                                    jsonDecode(response.body)
                                        ['accessToken'];

                                await prefs.setStringList(
                                    'user', [
                                  userjson['username'] ?? "",
                                  userjson['tel'] ?? "",
                                ]);

                                await prefs.setString(
                                    'token', tokenjson);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ShowProducts()),
                                );
                              }

                              ScaffoldMessenger.of(context) //  แสดงข้อความระหว่างการเข้าสู่ระบบ
                                  .showSnackBar(
                                const SnackBar( // แสดงข้อความระหว่างการเข้าสู่ระบบ
                                    content: Text(
                                        "กำลังเข้าสู่ระบบ...")),
                              );
                            }
                          },
                          child: const Text(
                            "LOGIN",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {},
                  child: const Text(
                    " Register ",
                    // "Create Account",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}

