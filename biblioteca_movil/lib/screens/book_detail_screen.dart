import 'package:flutter/material.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalle del Libro")),
      body: const Center(child: Text("Detalles del libro")),
    );
  }
}
