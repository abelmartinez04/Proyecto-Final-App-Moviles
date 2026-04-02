import 'package:flutter/material.dart';
import '../models/book_model.dart';

class EditBookScreen extends StatefulWidget {
  const EditBookScreen({super.key});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final genreController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final book = ModalRoute.of(context)!.settings.arguments as Book;

    titleController.text = book.title;
    authorController.text = book.author;
    genreController.text = book.genre;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Libro")),
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
                // Por ahora solo vuelve atrás (no guarda cambios aún)
                Navigator.pop(context);
              },
              child: const Text("Guardar cambios"),
            )
          ],
        ),
      ),
    );
  }
}