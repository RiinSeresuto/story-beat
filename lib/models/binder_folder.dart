import 'binder_item.dart';

class BinderFolder extends BinderItem {
  final List<BinderItem> children;

  const BinderFolder({
    required super.id,
    required super.name,
    required super.path,
    this.children = const [],
  });

  @override
  bool get isFolder => true;

  @override
  bool get isDocument => false;
}
