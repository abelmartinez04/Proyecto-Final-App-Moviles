import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Mi Biblioteca"), centerTitle: true),
      body: provider.books.isEmpty
          ? const Center(
              child: Text(
                "No tienes libros aún",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: provider.books.length,
              itemBuilder: (context, index) {
                final book = provider.books[index];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(
                      book.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("${book.author} • ${book.genre}"),
                    
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          book.status == "Leído"
                              ? Icons.check_circle
                              : Icons.schedule,
                          color: book.status == "Leído"
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                           Navigator.pushNamed(
                              context,
                              '/edit',
                              arguments: book,
                            );
                          },
                        ),
                      ],
                    ),

                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/detail',
                        arguments: book,
                      );
                    },
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}