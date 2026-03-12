class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String description;
  final String? image;
  final int? color;
  final int? productCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.description = '',
    this.image,
    this.color,
    this.productCount,
  });
}
