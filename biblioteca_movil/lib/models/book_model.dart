import 'category_model.dart';
import 'author_model.dart';

class BookModel {
  final String id;
  final String title;
  final String? description;
  final String? coverUrl;
  final String? status;
  final DateTime createdAt;
  final List<CategoryModel>? categories;
  final List<AuthorModel>? authors;

  BookModel({
    required this.id,
    required this.title,
    this.description,
    this.coverUrl,
    this.status,
    required this.createdAt,
    this.categories,
    this.authors,
  });

  // Getters de conveniencia para compatibilidad con la UI
  String get author => authors != null && authors!.isNotEmpty
      ? authors!.map((a) => a.name).join(', ')
      : 'Sin autor';

  String get genre => categories != null && categories!.isNotEmpty
      ? categories!.map((c) => c.name).join(', ')
      : 'Sin género';

  String get statusLabel {
    switch (status) {
      case 'read':
        return 'Leído';
      case 'reading':
        return 'En progreso';
      case 'pending':
        return 'Pendiente';
      default:
        return 'Pendiente';
    }
  }

  factory BookModel.fromJson(Map<String, dynamic> json) {
    var authorsList = <AuthorModel>[];
    if (json['authors'] != null) {
      authorsList = (json['authors'] as List)
          .map((e) => AuthorModel.fromJson(e))
          .toList();
    }

    var categoriesList = <CategoryModel>[];
    if (json['categories'] != null) {
      categoriesList = (json['categories'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
    }

    return BookModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      status: json['status'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      categories: categoriesList.isNotEmpty ? categoriesList : null,
      authors: authorsList.isNotEmpty ? authorsList : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cover_url': coverUrl,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
