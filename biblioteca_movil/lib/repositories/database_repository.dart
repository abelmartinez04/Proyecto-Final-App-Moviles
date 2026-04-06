import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/book_model.dart';
import '../models/category_model.dart';
import '../models/user_book_model.dart';

class DatabaseRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // Categorías
  Future<List<CategoryModel>> getCategories() async {
    final response = await _client.from('categories').select();
    return (response as List).map((e) => CategoryModel.fromJson(e)).toList();
  }

  // Libros públicos
  Future<List<BookModel>> getBooks() async {
    final response = await _client.from('books').select('*, authors(*), categories(*)');
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

  // Añadir un libro a mi lista
  Future<UserBookModel> addUserBook({
    required String userId,
    required String bookId,
    required String status,
    int? rating,
  }) async {
    final response = await _client.from('user_books').insert({
      'user_id': userId,
      'book_id': bookId,
      'status': status,
      'rating': rating,
    }).select('*, books(*, authors(*), categories(*))').single();
    
    return UserBookModel.fromJson(response);
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
