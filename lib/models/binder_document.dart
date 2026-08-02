import 'binder_item.dart';

class BinderDocument extends BinderItem {
  const BinderDocument({
    required super.id,
    required super.name,
    required super.path,
    super.parentId,
    this.isEditing = false,
  });

  final bool isEditing;

  BinderDocument copyWith({
    String? id,
    String? name,
    String? path,
    String? parentId,
    bool? isEditing,
  }) {
    return BinderDocument(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      parentId: parentId ?? this.parentId,
      isEditing: isEditing ?? this.isEditing,
    );
  }

  @override
  bool get isFolder => false;

  @override
  bool get isDocument => true;
}
