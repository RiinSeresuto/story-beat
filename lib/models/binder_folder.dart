import 'package:story_beat/models/binder_item.dart';

class BinderFolder extends BinderItem {
  const BinderFolder({
    required super.id,
    required super.name,
    required super.path,
    super.parentId,
    this.children = const [],
  });

  final List<BinderItem> children;

  BinderFolder copyWith({
    String? id,
    String? name,
    String? path,
    String? parentId,
    List<BinderItem>? children,
  }) {
    return BinderFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      parentId: parentId ?? this.parentId,
      children: children ?? this.children,
    );
  }

  @override
  bool get isFolder => true;

  @override
  bool get isDocument => false;
}
