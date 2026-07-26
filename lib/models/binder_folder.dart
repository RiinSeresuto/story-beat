import 'binder_item.dart';

class BinderFolder extends BinderItem {
  const BinderFolder({
    required super.id,
    required super.name,
    required super.path,
    super.parentId,
  });

  @override
  bool get isFolder => true;

  @override
  bool get isDocument => false;
}
