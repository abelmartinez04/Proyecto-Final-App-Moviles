import 'category_model.dart';

class BookModel {
  final String id;
  final String title;
  final String? author;
  final String? description;
  final String? coverUrl;
  final String? categoryId;
  final DateTime createdAt;
  final CategoryModel? category;

  BookModel({
    required this.id,
    required this.title,
    this.author,
    this.description,
    this.coverUrl,
    this.categoryId,
    required this.createdAt,
    this.category,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String?,
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      categoryId: json['category_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      category: json['categories'] != null 
          ? CategoryModel.fromJson(json['categories']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'cover_url': coverUrl,
      'category_id': categoryId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
