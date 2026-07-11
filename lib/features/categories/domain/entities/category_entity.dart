class CategoryEntity {
  const CategoryEntity({
    required this.id,
    required this.name,
    this.uid,
    this.description,
    this.imageUrl,
    this.position,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final int? uid;
  final String? description;
  final String? imageUrl;
  final int? position;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;
}
