//     final bookModel = bookModelFromJson(jsonString);     
// ignore_for_file: file_names

import 'dart:convert';

BookModel bookModelFromJson(String str) => BookModel.fromJson(json.decode(str));

String bookModelToJson(BookModel data) => json.encode(data.toJson());

class BookModel {
  final int id;
  final String title;
  final String author;
  final int? publishedYear;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    this.publishedYear,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      publishedYear: json['published_year'],
    );
  }


    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "author": author,
        "published_year": publishedYear,
    };
}


