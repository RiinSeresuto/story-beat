class TrashItem {
  const TrashItem({
    required this.originalPath,
    required this.trashPath,
    required this.name,
    required this.isFolder,
    required this.trashedAt,
  });

  final String originalPath;
  final String trashPath;
  final String name;
  final bool isFolder;
  final DateTime trashedAt;

  bool get isDocument => !isFolder;

  factory TrashItem.fromJson(Map<String, Object?> json) {
    return TrashItem(
      originalPath: json['originalPath'] as String,
      trashPath: json['trashPath'] as String,
      name: json['name'] as String,
      isFolder: json['isFolder'] as bool,
      trashedAt: DateTime.parse(json['trashedAt'] as String),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'originalPath': originalPath,
      'trashPath': trashPath,
      'name': name,
      'isFolder': isFolder,
      'trashedAt': trashedAt.toIso8601String(),
    };
  }
}
