abstract class BinderItem {
  final String id;
  final String name;
  final String path;
  final String? parentId;

  const BinderItem({
    required this.id,
    required this.name,
    required this.path,
    this.parentId,
  });

  bool get isFolder;

  bool get isDocument;
}
