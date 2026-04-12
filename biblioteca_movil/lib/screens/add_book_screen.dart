import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final genreController = TextEditingController();
  final urlController = TextEditingController();

  File? selectedImage;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Agregar Libro")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔥 PREVIEW IMAGEN
            if (selectedImage != null)
              Center(
                child: Container(
                  height: 220,
                  width: 140,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(selectedImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

            // 🔥 BOTÓN SELECCIONAR IMAGEN
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Seleccionar imagen"),
            ),

            const SizedBox(height: 16),

            _buildInput(titleController, "Título", Icons.book),
            _buildInput(authorController, "Autor", Icons.person),
            _buildInput(genreController, "Género", Icons.category),
            _buildInput(urlController, "URL del libro", Icons.link),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                String? imageUrl;

                // 🔥 SUBIR IMAGEN SI EXISTE
                if (selectedImage != null) {
                  imageUrl = await provider.uploadImage(selectedImage!);
                }

                await provider.addBook(
                  title: titleController.text,
                  authorName: authorController.text,
                  categoryName: genreController.text,
                  coverUrl: imageUrl,
                  bookUrl: urlController.text,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
