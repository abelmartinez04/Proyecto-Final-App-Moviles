import 'package:flutter/material.dart';
import '../models/book_model.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final book = ModalRoute.of(context)!.settings.arguments as BookModel;

    final authorText = book.authors != null && book.authors!.isNotEmpty
        ? book.authors!.map((a) => a.name).join(', ')
        : 'Sin autor';
    final genreText = book.categories != null && book.categories!.isNotEmpty
        ? book.categories!.map((c) => c.name).join(', ')
        : 'Sin género';

    String statusLabel;
    switch (book.status) {
      case 'read':
        statusLabel = 'Leído';
        break;
      case 'reading':
        statusLabel = 'En progreso';
        break;
      case 'pending':
        statusLabel = 'Pendiente';
        break;
      default:
        statusLabel = book.status ?? 'Sin estado';
    }

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
            Text("Autor: $authorText"),
            const SizedBox(height: 10),
            Text("Género: $genreText"),
            const SizedBox(height: 10),
            Text("Estado: $statusLabel"),
          ],
        ),
      ),
    );
  }
}
