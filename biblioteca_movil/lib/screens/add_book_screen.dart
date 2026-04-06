import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../models/book_model.dart';

class AddBookScreen extends StatelessWidget {
  const AddBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final genreController = TextEditingController();

    final provider = Provider.of<BookProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Agregar Libro")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Título"),
            ),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(labelText: "Autor"),
            ),
            TextField(
              controller: genreController,
              decoration: const InputDecoration(labelText: "Género"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                provider.addBook(
                  Book(
                    title: titleController.text,
                    author: authorController.text,
                    genre: genreController.text,
                    status: "Pendiente",
                  ),
                );

                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            )
          ],
        ),
      ),
    );
  }
}
