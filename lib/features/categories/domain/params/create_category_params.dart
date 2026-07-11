import 'dart:typed_data';

class CreateCategoryParams {
  const CreateCategoryParams({
    required this.name,
    required this.description,
    required this.position,
    required this.isActive,
    this.imageBytes,
    this.imageFileName,
  });

  final String name;
  final String description;
  final int position;
  final bool isActive;
  final Uint8List? imageBytes;
  final String? imageFileName;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'position': position,
      'is_active': isActive ? 1 : 0,
    };
  }
}
