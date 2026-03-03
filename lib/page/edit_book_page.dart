import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lab10/models/BookMode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditBookPage extends StatefulWidget {
  final BookModel book;

  const EditBookPage({super.key, required this.book});

  @override
  State<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {

  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController authorController;
  late TextEditingController yearController;

  @override
  void initState() {
    super.initState();

    /// โหลดค่าหนังสือเดิม
    titleController =
        TextEditingController(text: widget.book.title);

    authorController =
        TextEditingController(text: widget.book.author);

    yearController = TextEditingController(
        text: widget.book.publishedYear.toString());
  }

  /// ================= UPDATE =================
  Future<void> updateBook() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    var body = jsonEncode({
      "title": titleController.text,
      "author": authorController.text,

      /// ⭐ สำคัญมาก
      "published_year":
          int.tryParse(yearController.text) ?? 0,
    });

    var response = await http.put(
      Uri.parse(
        "http://10.0.2.2:3000/api/books/${widget.book.id}",
      ),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer $token",
      },
      body: body,
    );

    print("UPDATE STATUS = ${response.statusCode}");
    print("UPDATE BODY = ${response.body}");

    if (response.statusCode == 200) {
      Navigator.pop(context, true); // refresh list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("แก้ไขไม่สำเร็จ")),
      );
    }
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("แก้ไขหนังสือ"),
        backgroundColor: const Color(0xFFB155C3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: authorController,
                decoration: const InputDecoration(
                  labelText: "Author",
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Published Year",
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: updateBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFB155C3),
                  ),
                  child: const Text("SAVE"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}