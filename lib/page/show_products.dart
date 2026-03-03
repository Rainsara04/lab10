import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lab10/models/BookMode.dart';
import 'package:lab10/page/add_product.dart';
import 'package:lab10/page/edit_book_page.dart';
import 'package:lab10/page/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowProducts extends StatefulWidget {
  const ShowProducts({super.key});

  @override
  State<ShowProducts> createState() => _ShowProductsState();
}

class _ShowProductsState extends State<ShowProducts> {
  List<BookModel>? books;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getList();
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("รายการหนังสือ",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFB155C3),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F9FF),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : books == null || books!.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: books!.length,
                  itemBuilder: (context, index) {
                    final book = books![index];
                    return _buildBookCard(book);
                  },
                ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AddProductPage()),
          ).then((_) => getList());
        },
      ),
    );
  }

  /// ================= BOOK CARD =================
  Widget _buildBookCard(BookModel book) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        /// ⭐ EDIT (เพิ่ม)
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditBookPage(book: book),
            ),
          );

          if (result == true) {
            getList();
          }
        },

        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFD1E3FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.menu_book_rounded,
              color: Color.fromARGB(255, 74, 145, 226)),
        ),

        title: Text(
          book.title,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF334E68)),
        ),

        subtitle: Text(
          "ผู้แต่ง: ${book.author}\nปีที่พิมพ์: ${book.publishedYear == 0 ? '-' : book.publishedYear}",
        ),

        trailing: IconButton(
          icon:
              const Icon(Icons.delete_forever, color: Colors.red),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("ยืนยันการลบ"),
                content: Text(
                    "คุณต้องการลบ \"${book.title}\" ใช่หรือไม่?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("ยกเลิก"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent),
                    onPressed: () {
                      Navigator.pop(context);
                      deleteBook(book.id);
                    },
                    child: const Text("ลบเลย",
                        style:
                            TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child:
          Text("ไม่พบข้อมูลหนังสือ", style: TextStyle(color: Colors.grey)),
    );
  }

  /// ================= GET LIST =================
  Future<void> getList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      var response = await http.get(
        Uri.parse("http://10.0.2.2:3000/api/books"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var jsonStr = jsonDecode(response.body);

        setState(() {
          books = (jsonStr['message'] as List)
              .map((e) => BookModel.fromJson(e))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Catch Error: $e");
    }
  }

  /// ================= DELETE =================
  Future<void> deleteBook(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    var response = await http.delete(
      Uri.parse("http://10.0.2.2:3000/api/books/$id"),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == 200 ||
        response.statusCode == 204) {
      getList();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ลบหนังสือเรียบร้อย')),
      );
    }
  }
}