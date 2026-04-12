import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Biblioteca"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await provider.loadPublicData();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Datos actualizados ✅")),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // BUSCADOR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) {
                provider.searchBooks(value);
              },
              decoration: InputDecoration(
                hintText: "Buscar por título, autor o género...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      await provider.loadPublicData();
                    },
                    child: provider.filteredBooks.isEmpty
                        ? const Center(
                            child: Text(
                              "No hay resultados 📭",
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: provider.filteredBooks.length,
                            itemBuilder: (context, index) {
                              final book = provider.filteredBooks[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),

                                  // IMAGEN DEL LIBRO
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child:
                                        book.coverUrl != null &&
                                            book.coverUrl!.isNotEmpty
                                        ? Image.network(
                                            book.coverUrl!,
                                            width: 50,
                                            height: 70,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return _placeholderImage();
                                                },
                                          )
                                        : _placeholderImage(),
                                  ),

                                  title: Text(
                                    book.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),

                                  subtitle: Text(
                                    "${book.author} • ${book.genre}",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        book.statusLabel == "Leído"
                                            ? Icons.check_circle
                                            : Icons.menu_book,
                                        color: book.statusLabel == "Leído"
                                            ? Colors.green
                                            : Colors.indigo,
                                      ),

                                      const SizedBox(width: 8),

                                      // EDITAR
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

                                      // ELIMINAR
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          _confirmDelete(
                                            context,
                                            provider,
                                            book.id,
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
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // PLACEHOLDER IMAGEN
  Widget _placeholderImage() {
    return Container(
      width: 50,
      height: 70,
      color: Colors.indigo.shade100,
      child: const Icon(Icons.menu_book, color: Colors.indigo),
    );
  }

  // ELIMINACIÓN
  void _confirmDelete(
    BuildContext context,
    BookProvider provider,
    String bookId,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Eliminar libro"),
          content: const Text("¿Seguro que quieres eliminar este libro?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                // 👇 aquí luego conectamos con DB real
                // await provider.deleteBook(bookId);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Libro eliminado (demo) 🗑️")),
                );
              },
              child: const Text(
                "Eliminar",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
