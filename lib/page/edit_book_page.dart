import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditBookPage extends StatefulWidget {
  const EditBookPage({super.key});

  @override
  State<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final _formKey = GlobalKey<FormState>();
  
  // Controller สำหรับช่องกรอกข้อมูล
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  
  bool _isLoading = false;
  int? bookId;

  // 🌊 ใช้ชุดสีฟ้าน้ำทะเลเดิม
  final Color oceanDeep = const Color(0xFF0077B6);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // รับค่า ID ที่ส่งมาจากหน้า ShowProducts
    if (bookId == null) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args != null && args is int) {
        bookId = args;
        _fetchBookDetails(); // ดึงข้อมูลเก่ามาแสดงทันที
      }
    }
  }

  // ฟังก์ชันดึงข้อมูลหนังสือเดิมจาก API
  Future<void> _fetchBookDetails() async {
    setState(() => _isLoading = true);
    try {
      final SharedPreferences prefs = await _prefs;
      final token = prefs.getString('token') ?? "";
      
      var url = Uri.parse("http://10.0.2.2:3000/api/books/$bookId");
      var response = await http.get(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['payload'];
        setState(() {
          _titleController.text = data['title'];
          _authorController.text = data['author'];
          _yearController.text = data['published_year'].toString();
        });
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ฟังก์ชันส่งข้อมูลการแก้ไข (Update)
  Future<void> _updateBook() async {
    final SharedPreferences prefs = await _prefs;

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        var data = jsonEncode({
          "title": _titleController.text,
          "author": _authorController.text,
          "published_year": int.parse(_yearController.text),
        });

        var url = Uri.parse("http://10.0.2.2:3000/api/books/$bookId");
        var response = await http.put(
          url,
          body: data,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'Bearer ${prefs.getString('token')}',
          },
        );

        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("แก้ไขข้อมูลสำเร็จ!"), backgroundColor: Colors.green),
            );
            Navigator.pop(context); // กลับไปหน้าแสดงรายการ
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("แก้ไขไม่สำเร็จ: ${response.statusCode}"), backgroundColor: Colors.red),
            );
          }
        }
      } catch (e) {
        debugPrint("Update Error: $e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EDIT BOOK", style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: _isLoading && _titleController.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Book Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: oceanDeep)),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(hintText: "Book Title", prefixIcon: Icon(Icons.book_outlined)),
                      validator: (value) => value!.isEmpty ? "กรุณากรอกชื่อหนังสือ" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _authorController,
                      decoration: const InputDecoration(hintText: "Author Name", prefixIcon: Icon(Icons.person_outline)),
                      validator: (value) => value!.isEmpty ? "กรุณากรอกชื่อผู้แต่ง" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: "Published Year", prefixIcon: Icon(Icons.calendar_today_outlined)),
                      validator: (value) => value!.isEmpty ? "กรุณากรอกปีที่พิมพ์" : null,
                    ),
                    const SizedBox(height: 40),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 55,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          backgroundColor: oceanDeep, // ใช้สีฟ้าเดิม
        ),
        onPressed: _isLoading ? null : _updateBook,
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("บันทึกการแก้ไข", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}