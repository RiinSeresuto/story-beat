import 'binder_item.dart';

class BinderDocument extends BinderItem {
  const BinderDocument({
    required super.id,
    required super.name,
    required super.path,
    super.parentId,
  });

  @override
  bool get isFolder => false;

  @override
  bool get isDocument => true;
}
