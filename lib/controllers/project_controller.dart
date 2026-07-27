import 'package:flutter/foundation.dart';

import '../models/binder_item.dart';
import '../models/project.dart';
import '../services/filesystem_service.dart';

class ProjectController extends ChangeNotifier {
  ProjectController({required FilesystemService filesystem})
    : _filesystem = filesystem;

  final FilesystemService _filesystem;

  Project? _project;
  List<BinderItem> _binderItems = [];
  BinderItem? _selectedItem;
  bool _loading = false;

  Project? get project => _project;
  List<BinderItem> get binderItems => List.unmodifiable(_binderItems);
  BinderItem? get selectedItem => _selectedItem;
  bool get isLoading => _loading;

  Future<void> openProject() async {
    _loading = true;
    notifyListeners();

    try {
      final result = await _filesystem.openProject();

      if (result == null) {
        return;
      }

      final binderItems = await _filesystem.loadBinder(result.path);

      _project = result;
      _binderItems = binderItems;
      _selectedItem = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void selectItem(BinderItem item) {
    _selectedItem = item;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_project == null) return;

    _binderItems = await _filesystem.loadBinder(_project!.path);

    notifyListeners();
  }
}
