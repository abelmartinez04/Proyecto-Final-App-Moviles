import 'package:flutter/material.dart';
import '../models/book_model.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final book = ModalRoute.of(context)!.settings.arguments as BookModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle del Libro"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text("Autor: ${book.author}"),
            const SizedBox(height: 10),
            Text("Género: ${book.genre}"),
            const SizedBox(height: 10),
            Text("Estado: ${book.statusLabel}"),
          ],
        ),
      ),
    );
  }
}
