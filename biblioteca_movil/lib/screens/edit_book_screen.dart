import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import '../providers/book_provider.dart';

class EditBookScreen extends StatefulWidget {
  const EditBookScreen({super.key});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final genreController = TextEditingController();
  String _selectedStatus = 'pending';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final book = ModalRoute.of(context)!.settings.arguments as BookModel;

    titleController.text = book.title;
    authorController.text = book.authors != null && book.authors!.isNotEmpty
        ? book.authors!.map((a) => a.name).join(', ')
        : '';
    genreController.text = book.categories != null && book.categories!.isNotEmpty
        ? book.categories!.map((c) => c.name).join(', ')
        : '';
    _selectedStatus = book.status ?? 'pending';
  }

  @override
  Widget build(BuildContext context) {
    final book = ModalRoute.of(context)!.settings.arguments as BookModel;

    return Scaffold(
      appBar: AppBar(title: const Text("Editar Libro")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Título"),
              readOnly: true,
            ),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(labelText: "Autor"),
              readOnly: true,
            ),
            TextField(
              controller: genreController,
              decoration: const InputDecoration(labelText: "Género"),
              readOnly: true,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(labelText: "Estado"),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Pendiente')),
                DropdownMenuItem(value: 'reading', child: Text('En progreso')),
                DropdownMenuItem(value: 'read', child: Text('Leído')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final provider = Provider.of<BookProvider>(context, listen: false);
                await provider.updateBookStatus(book.id, _selectedStatus);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Guardar cambios"),
            )
          ],
        ),
      ),
    );
  }
}