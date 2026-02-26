import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lab10/models/BookMode.dart';
import 'package:lab10/page/add_product.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ShowProducts extends StatefulWidget {
  const ShowProducts({super.key});

  @override
  State<ShowProducts> createState() => _ShowProductsState();
}

class _ShowProductsState extends State<ShowProducts> {
  List<BookModel>? books;
  bool isLoading = true;
  
  VoidCallback? get logout => null; // เพิ่มตัวแปรเช็คสถานะการโหลด

  @override
  void initState() {
    super.initState();
    getList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "รายการหนังสือ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFB155C3), // สีพื้นหลังของ AppBar
        foregroundColor: Colors.white, // สีของข้อความบน AppBar
        centerTitle: true,
        elevation: 0,

        actions: [
          IconButton(onPressed: logout,
           icon: const Icon(Icons.logout,)
           ),
        ],
      ),

    
      backgroundColor: const Color(0xFFF5F9FF), // พื้นหลังฟ้าพาสเทลอ่อน
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            ) // แสดงวงกลมหมุนตอนโหลด
          : books == null || books!.isEmpty
          ? _buildEmptyState() // ถ้าไม่มีข้อมูล
          : ListView.builder(
              padding: const EdgeInsets.all(15), // เพิ่ม padding รอบๆ ListView
              itemCount: books!.length,
              itemBuilder: (context, index) {
                final book = books![index];
                return _buildBookCard(book);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductPage()),
          ).then((value) => setState(() { 
            getList(); // รีเฟรชข้อมูลเมื่อกลับมาจากหน้าเพิ่มหนังสือ
           }) );
          
          
        },
        child: Icon(Icons.add),
      ),
    );
  }


  // UI สำหรับ Card หนังสือแบบ Minimal
  Widget _buildBookCard(BookModel book) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(
        bottom: 15,
      ), // เพิ่ม margin ระหว่างการ์ดแต่ละใบ
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(
          color: Color.fromARGB(255, 0, 0, 1),
        ), // สีของเส้นขอบการ์ด
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFD1E3FF), // สีพื้นหลังของไอคอน
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            color: Color.fromARGB(255, 74, 145, 226),
          ), // สีของไอคอน
        ),

        title: Text(
          book.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF334E68),
          ), // สีของชื่อหนังสือ
        ),
        subtitle: Text(
          "ผู้แต่ง: ${book.author}\nปีที่พิมพ์: ${book.publishedYear}",
        ),
        trailing: IconButton(
        onPressed: () {
          // เพิ่ม Pop-up ยืนยันการลบตรงนี้
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: const Text(
                  "ยืนยันการลบ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text("คุณต้องการลบหนังสือเรื่อง \"${book.title}\" ใช่หรือไม่?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context), // ปิดป๊อบอัพ
                    child: const Text(
                      "ยกเลิก",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: ใส่คำสั่งลบข้อมูล (เช่น deleteBook(book.id))
                      deleteBook(book.id);
                      Navigator.pop(context); // ปิดป๊อบอัพหลังลบ
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "ลบเลย",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          );
        },
        icon: const Icon(
          Icons.delete_forever,
          color: Colors.red,
        ),
      ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text("ไม่พบข้อมูลหนังสือ", style: TextStyle(color: Colors.grey)),
    );
  }

  Future<void> getList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      var url = Uri.parse("http://10.0.2.2:3000/api/books");
      var response = await http.get(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );
      

      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var jsonStr = jsonDecode(response.body);

        // แก้ไขตรงนี้: เช็คก่อนว่า message ไม่เป็น null
        if (jsonStr['message'] != null) {
          setState(() {
            // ต้องครอบ ( ) และใส่ .toList() ที่ท้ายสุด
            books = (jsonStr['message'] as List)
                .map((item) => BookModel.fromJson(item))
                .toList();
            isLoading = false;
          });
        }
      } else {
        setState(() => isLoading = false);
        debugPrint("Error: Status Code ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Catch Error: $e");
    }
  }

  // ฟังก์ชันลบหนังสือจากเซิร์ฟเวอร์แล้วรีเฟรชรายการ
  Future<void> deleteBook(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";
      if (token.isEmpty) {
        debugPrint('deleteBook: no token available');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่มีสิทธิ์ลบ (token หาย)')),
        );
        return;
      }

      var url = Uri.parse("http://10.0.2.2:3000/api/books/$id");
      debugPrint('deleteBook called with id=$id, token=$token');
      var response = await http.delete(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      debugPrint('Delete response status: ${response.statusCode}');
      debugPrint('Delete response body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 204) {
        // ถ้าลบสำเร็จ รีเฟรชหน้าและลบจาก local list ทันที
        setState(() {
          books?.removeWhere((b) => b.id == id);
        });
        // ยังเรียก getList เผื่อ server เปลี่ยนแปลงมากกว่า
        getList();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบหนังสือเรียบร้อย')),
        );
      } else {
        debugPrint('Failed to delete: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบไม่สำเร็จ')), 
        );
      }
    } catch (e) {
      debugPrint("Delete error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาด')), 
      );
    }
  }
}
