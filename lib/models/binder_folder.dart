import 'package:story_beat/models/binder_item.dart';

class BinderFolder extends BinderItem {
  const BinderFolder({
    required super.id,
    required super.name,
    required super.path,
    super.parentId,
    this.children = const [],
    this.isEditing = false,
  });

  final List<BinderItem> children;
  final bool isEditing;

  BinderFolder copyWith({
    String? id,
    String? name,
    String? path,
    String? parentId,
    List<BinderItem>? children,
    bool? isEditing,
  }) {
    return BinderFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      parentId: parentId ?? this.parentId,
      children: children ?? this.children,
      isEditing: isEditing ?? this.isEditing,
    );
  }

  @override
  bool get isFolder => true;

  @override
  bool get isDocument => false;
}
