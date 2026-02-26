import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductState();
}

class _AddProductState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _publishedYearController = TextEditingController();

  final Future<SharedPreferences> _prefs =
      SharedPreferences.getInstance();

  Future<void> addProduct() async {
    SharedPreferences prefs = await _prefs;
    final String token = prefs.getString('token') ?? "";

    var data = jsonEncode({
      "title": _titleController.text,
      "author": _authorController.text,
      "published_year":
          int.parse(_publishedYearController.text),
    });

    var url = Uri.parse("http://10.0.2.2:3000/api/books");

    var response = await http.post(
      url,
      body: data,
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer $token",
      },
    );

    debugPrint("Response Body: ${response.body}");

    if (response.statusCode == 201) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("เพิ่มหนังสือไม่สำเร็จ")),
      );
    }
  }

  InputDecoration inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color.fromARGB(255, 220, 122, 224)),//  สีของไอคอน
      filled: true,
      fillColor: Colors.purple.shade50, // สีพื้นหลังของ TextField
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide:
            const BorderSide(color: Color(0xFFB155C3), width: 2),// สีของเส้นขอบเมื่อโฟกัส
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("เพิ่มหนังสือ",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFB155C3), // สีพื้นหลังของ AppBar
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: inputStyle(
                        "ชื่อหนังสือ", Icons.menu_book),
                    validator: (v) =>
                        v!.isEmpty ? "กรอกชื่อหนังสือ" : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _authorController,
                    decoration:
                        inputStyle("ผู้แต่ง", Icons.person),
                    validator: (v) =>
                        v!.isEmpty ? "กรอกชื่อผู้แต่ง" : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _publishedYearController,
                    keyboardType: TextInputType.number,
                    decoration: inputStyle(
                        "ปีพิมพ์", Icons.calendar_today),
                    validator: (v) =>
                        v!.isEmpty ? "กรอกปีพิมพ์" : null,
                  ),
                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text(
                        "เพิ่มหนังสือ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFB155C3),// สีพื้นหลังของปุ่ม
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!
                            .validate()) {
                          addProduct();
                        }
                      },
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