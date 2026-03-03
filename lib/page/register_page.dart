import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final _formKey = GlobalKey<FormState>();

  final username = TextEditingController();
  final password = TextEditingController();
  final tel = TextEditingController();

  Future<void> register() async {

    if (!_formKey.currentState!.validate()) return;

    var json = jsonEncode({
      "username": username.text,
      "password": password.text,
      "tel": tel.text,
    });

    var response = await http.post(
      Uri.parse("http://10.0.2.2:3000/api/auth/register"),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json"
      },
      body: json,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("สมัครสมาชิกสำเร็จ")),
      );

      Navigator.pop(context); // กลับ login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("สมัครไม่สำเร็จ")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              TextFormField(
                controller: username,
                decoration:
                    const InputDecoration(labelText: "Username"),
                validator: (v) =>
                    v!.isEmpty ? "กรอก username" : null,
              ),

              TextFormField(
                controller: tel,
                decoration:
                    const InputDecoration(labelText: "Tel"),
              ),

              TextFormField(
                controller: password,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: "Password"),
                validator: (v) =>
                    v!.isEmpty ? "กรอก password" : null,
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: register,
                child: const Text("REGISTER"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}