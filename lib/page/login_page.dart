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
  // bool _isPasswordVisible = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
      return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5), // ม่วงพาสเทลอ่อน
      body: Center(
        child: SingleChildScrollView(
            child: Form(    // เพิ่ม Form
              key: _formKey,// เพิ่ม Form และกำหนด key
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 32, 
                    fontWeight: FontWeight.bold, 
                    color: Color.fromARGB(255, 159, 125, 216), 
                  ),
                ),
                const SizedBox(height: 40),

                /// Username
                TextFormField(
                  controller: _usernameController, // เพิ่ม controller
                  validator: (value) { // เพิ่ม validator
                    if (value == null || value.isEmpty) {
                      return "กรอก username";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Username",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// Password
                TextFormField(
                  controller: _passwordController, // เพิ่ม controller
                  obscureText: true,
                  validator: (value) { // เพิ่ม validator
                    if (value == null || value.isEmpty) {
                      return "กรอก password";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Password",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 30), 

                /// Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 177, 85, 195), // สีพื้นหลังของปุ่ม
                      foregroundColor: Colors.white, // สีของข้อความบนปุ่ม
                      side: const BorderSide(
                        color: Color.fromARGB(255, 243, 169, 50), // สีของเส้นขอบ 
                        width: 2, // ความหนาของเส้นขอบ
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), 
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // ทำการเข้าสู่ระบบ
                        debugPrint(_usernameController.text); // แสดง username ที่กรอก
                        debugPrint(_passwordController.text); // แสดง password ที่กรอก

                        var json = jsonEncode({
                          "username": _usernameController.text, // ส่ง username ในรูปแบบ JSON
                          "password": _passwordController.text,
                        });
                        // await prefs.setString("token", "your_token_here"); // เก็บ token ใน SharedPreferences
                        var url = Uri.parse("http://10.0.2.2:3000/api/auth/login"); // เปลี่ยนเป็น URL ของ API ที่ต้องการ            );

                        var response = await http.post(
                          url,
                          body: json, 
                          headers: {
                            HttpHeaders.contentTypeHeader: "application/json" // กำหนด header ว่าเป็น JSON
                          },
                        ); 
                          debugPrint(response.body);// ถ้ากรอกครบแล้ว จะทำงานตรงนี้ //
                          debugPrint("Login สำเร็จ"); // แสดงข้อความว่า Login สำเร็จ //

                        if (response.statusCode == 200) {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          // var data = jsonDecode(response.body);
                          var userjson = jsonDecode(response.body)['payload']; // แปลง response เป็น JSON และดึงข้อมูล payload
                          var tokenjson = jsonDecode(response.body)['token']; // ดึง token จาก response
                          if (userjson != null) {await prefs.setStringList('user',[
                            userjson['username'] ?? "", // เก็บ username ใน SharedPreferences
                            userjson['tel'] ?? "", // เก็บเบอร์โทรศัพท์ใน SharedPreferences 
                          ]);
                          }
                          if (tokenjson != null) {
                            await prefs.setString('token', tokenjson);// เก็บ token ใน SharedPreferences
                          debugPrint(tokenjson.toString()); // แสดง token ที่ได้รับ
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ShowProducts()),
                          );
                        }// นำไปหน้า ShowProducts
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("กำลังเข้าสู่ระบบ..."),
                          ),
                        );             
                      }
                    },
                      child: const Text("Login"),
                  ),
                ),

                const SizedBox(height: 16),

                /// Register Button
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Register",
                    style: TextStyle(
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
    );
  }
}

