import 'package:flutter/material.dart';
import '../models/book_model.dart';

class BookProvider extends ChangeNotifier {
  List<Book> books = [
    Book(
      title: "El Principito",
      author: "Antoine de Saint-Exupéry",
      genre: "Ficción",
      status: "Leído",
    ),
  ];

  void addBook(Book book) {
    books.add(book);
    notifyListeners();
  }

  void deleteBook(int index) {
    books.removeAt(index);
    notifyListeners();
  }
}
