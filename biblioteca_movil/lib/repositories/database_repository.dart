import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/book_model.dart';
import '../models/category_model.dart';
import '../models/user_book_model.dart';
import 'dart:io';

class DatabaseRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // Categorías
  Future<List<CategoryModel>> getCategories() async {
    final response = await _client.from('categories').select();
    return (response as List).map((e) => CategoryModel.fromJson(e)).toList();
  }

  // Libros públicos
  Future<List<BookModel>> getBooks() async {
    final response = await _client
        .from('books')
        .select('*, authors(*), categories(*)');
    return (response as List).map((e) => BookModel.fromJson(e)).toList();
  }

  // Mis libros (requiere Auth)
  Future<List<UserBookModel>> getUserBooks(String userId) async {
    final response = await _client
        .from('user_books')
        .select('*, books(*, authors(*), categories(*))')
        .eq('user_id', userId);
    return (response as List).map((e) => UserBookModel.fromJson(e)).toList();
  }

  // Crear un libro nuevo con autor y categoría (maneja las tablas pivote)
  Future<BookModel> createBook({
    required String title,
    String? authorName,
    String? categoryName,
    String? coverUrl,
    String? bookUrl,
  }) async {
    final bookResponse = await _client
        .from('books')
        .insert({
          'title': title,
          'status': 'pending',
          'cover_url': coverUrl,
          'book_url': bookUrl,
        })
        .select()
        .single();

    final bookId = bookResponse['id'] as String;

    // Autor
    if (authorName != null && authorName.isNotEmpty) {
      await _client.from('authors').upsert({
        'name': authorName,
      }, onConflict: 'name');

      final authorResponse = await _client
          .from('authors')
          .select('id')
          .eq('name', authorName)
          .single();

      await _client.from('book_authors').insert({
        'book_id': bookId,
        'author_id': authorResponse['id'],
      });
    }

    // Categoría
    if (categoryName != null && categoryName.isNotEmpty) {
      await _client.from('categories').upsert({
        'name': categoryName,
      }, onConflict: 'name');

      final categoryResponse = await _client
          .from('categories')
          .select('id')
          .eq('name', categoryName)
          .single();

      await _client.from('book_categories').insert({
        'book_id': bookId,
        'category_id': categoryResponse['id'],
      });
    }

    final fullBook = await _client
        .from('books')
        .select('*, authors(*), categories(*)')
        .eq('id', bookId)
        .single();

    return BookModel.fromJson(fullBook);
  }

  // Actualizar el status de un libro
  Future<BookModel> updateBookStatus(String bookId, String status) async {
    final response = await _client
        .from('books')
        .update({'status': status})
        .eq('id', bookId)
        .select('*, authors(*), categories(*)')
        .single();
    return BookModel.fromJson(response);
  }

  // Añadir un libro a mi lista
  Future<UserBookModel> addUserBook({
    required String userId,
    required String bookId,
    required String status,
    int? rating,
  }) async {
    final response = await _client
        .from('user_books')
        .insert({
          'user_id': userId,
          'book_id': bookId,
          'status': status,
          'rating': rating,
        })
        .select('*, books(*, authors(*), categories(*))')
        .single();

    return UserBookModel.fromJson(response);
  }

  Future<String> uploadImage(File file) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();

    await _client.storage.from('book-covers').upload(fileName, file);

    final publicUrl = _client.storage
        .from('book-covers')
        .getPublicUrl(fileName);

    return publicUrl;
  }

  // Actualizar estado o rating de mi libro
  Future<UserBookModel> updateUserBook({
    required String userBookId,
    String? status,
    int? rating,
  }) async {
    final updates = <String, dynamic>{};
    if (status != null) updates['status'] = status;
    if (rating != null) updates['rating'] = rating;

    final response = await _client
        .from('user_books')
        .update(updates)
        .eq('id', userBookId)
        .select('*, books(*, authors(*), categories(*))')
        .single();

    return UserBookModel.fromJson(response);
  }

  // Eliminar un libro de mi lista
  Future<void> deleteUserBook(String userBookId) async {
    await _client.from('user_books').delete().eq('id', userBookId);
  }
}
