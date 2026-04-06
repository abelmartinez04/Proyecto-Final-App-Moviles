import 'book_model.dart';

class UserBookModel {
  final String id;
  final String userId;
  final String bookId;
  final String status;
  final int? rating;
  final DateTime addedAt;
  final BookModel? book;

  UserBookModel({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.status,
    this.rating,
    required this.addedAt,
    this.book,
  });

  factory UserBookModel.fromJson(Map<String, dynamic> json) {
    return UserBookModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      bookId: json['book_id'] as String,
      status: json['status'] as String,
      rating: json['rating'] as int?,
      addedAt: DateTime.parse(json['added_at'] as String),
      book: json['books'] != null ? BookModel.fromJson(json['books']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'book_id': bookId,
      'status': status,
      'rating': rating,
      'added_at': addedAt.toIso8601String(),
    };
  }
}
