import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../models/category_model.dart';
import '../models/user_book_model.dart';
import '../repositories/database_repository.dart';
import '../repositories/auth_repository.dart';

class BookProvider extends ChangeNotifier {
  final DatabaseRepository _dbRepo;
  final AuthRepository _authRepo;

  List<BookModel> _publicBooks = [];
  List<CategoryModel> _categories = [];
  List<UserBookModel> _userBooks = [];
  bool _isLoading = false;

  List<BookModel> get publicBooks => _publicBooks;
  List<CategoryModel> get categories => _categories;
  List<UserBookModel> get userBooks => _userBooks;
  bool get isLoading => _isLoading;

  BookProvider(this._dbRepo, this._authRepo) {
    loadPublicData();
    if (_authRepo.currentUser != null) {
      loadUserBooks();
    }
  }

  Future<void> loadPublicData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _categories = await _dbRepo.getCategories();
      _publicBooks = await _dbRepo.getBooks();
    } catch (e) {
      debugPrint("Error loading public data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserBooks() async {
    final userId = _authRepo.currentUser?.id;
    if (userId == null) return;
    
    _isLoading = true;
    notifyListeners();
    try {
      _userBooks = await _dbRepo.getUserBooks(userId);
    } catch (e) {
      debugPrint("Error loading user books: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBookToMyList(String bookId, String status, {int? rating}) async {
    final userId = _authRepo.currentUser?.id;
    if (userId == null) return;

    try {
      final newUserBook = await _dbRepo.addUserBook(
        userId: userId,
        bookId: bookId,
        status: status,
        rating: rating,
      );
      _userBooks.add(newUserBook);
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding book to my list: $e");
    }
  }
  
  Future<void> updateMyBookStatus(String userBookId, String status, {int? rating}) async {
    try {
      final updatedBook = await _dbRepo.updateUserBook(
        userBookId: userBookId, 
        status: status,
        rating: rating,
      );
      final index = _userBooks.indexWhere((b) => b.id == userBookId);
      if (index != -1) {
        _userBooks[index] = updatedBook;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating my book: $e");
    }
  }

  // Crear un libro nuevo con autor y categoría (persiste en Supabase)
  Future<void> addBook({
    required String title,
    String? authorName,
    String? categoryName,
  }) async {
    try {
      final newBook = await _dbRepo.createBook(
        title: title,
        authorName: authorName,
        categoryName: categoryName,
      );
      _publicBooks.add(newBook);
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding book: $e");
    }
  }

  // Actualizar el status de un libro público
  Future<void> updateBookStatus(String bookId, String status) async {
    try {
      final updatedBook = await _dbRepo.updateBookStatus(bookId, status);
      final index = _publicBooks.indexWhere((b) => b.id == bookId);
      if (index != -1) {
        _publicBooks[index] = updatedBook;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating book status: $e");
    }
  }
}
