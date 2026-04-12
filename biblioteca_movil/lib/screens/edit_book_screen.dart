import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  File? selectedImage;
  String? currentImageUrl;

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
  void didChangeDependencies() {
    super.didChangeDependencies();

    final book = ModalRoute.of(context)!.settings.arguments as BookModel;

    titleController.text = book.title;
    authorController.text = book.author;
    genreController.text = book.genre;
    currentImageUrl = book.coverUrl;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Editar Libro")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (selectedImage != null)
              _imagePreview(FileImage(selectedImage!))
            else if (currentImageUrl != null && currentImageUrl!.isNotEmpty)
              _imagePreview(NetworkImage(currentImageUrl!)),

            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Cambiar imagen"),
            ),

            const SizedBox(height: 16),

            _buildInput(titleController, "Título", Icons.book),
            _buildInput(authorController, "Autor", Icons.person),
            _buildInput(genreController, "Género", Icons.category),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                if (selectedImage != null) {
                  await provider.uploadImage(selectedImage!);
                }

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Guardar cambios"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePreview(ImageProvider image) {
    return Center(
      child: Container(
        height: 220,
        width: 140,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(image: image, fit: BoxFit.cover),
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
