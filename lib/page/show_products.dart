import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

List books = [];

class ShowProducts extends StatelessWidget {
  const ShowProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

Future<void> getList() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token") ?? "";

  var url = Uri.parse("http://10.0.2.2:3000/api/books");

  var response = await http.get(
    url,
    headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    books = jsonDecode(response.body);
  }
}
