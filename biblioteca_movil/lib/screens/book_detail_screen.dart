import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/book_model.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final book = ModalRoute.of(context)!.settings.arguments as BookModel;

    return Scaffold(
      appBar: AppBar(title: const Text("Detalle del Libro")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                    ? Image.network(
                        book.coverUrl!,
                        height: 250,
                        width: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _placeholderImage();
                        },
                      )
                    : _placeholderImage(),
              ),
            ),

            const SizedBox(height: 20),

            // TÍTULO
            Text(
              book.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // AUTOR
            Text("Autor: ${book.author}", style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 8),

            // GÉNERO
            Text("Género: ${book.genre}", style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Estado: "),
                Icon(
                  book.statusLabel == "Leído"
                      ? Icons.check_circle
                      : Icons.menu_book,
                  color: book.statusLabel == "Leído"
                      ? Colors.green
                      : Colors.indigo,
                ),
                const SizedBox(width: 5),
                Text(book.statusLabel),
              ],
            ),

            const SizedBox(height: 20),

            // BOTÓN ABRIR LIBRO
            if (book.bookUrl != null && book.bookUrl!.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(book.bookUrl!);

                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text("Abrir libro"),
              ),
          ],
        ),
      ),
    );
  }

  // PLACEHOLDER SI NO HAY IMAGEN
  Widget _placeholderImage() {
    return Container(
      height: 250,
      width: 160,
      color: Colors.indigo.shade100,
      child: const Icon(Icons.menu_book, size: 50, color: Colors.indigo),
    );
  }
}
