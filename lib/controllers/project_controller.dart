import 'package:flutter/foundation.dart';
import 'package:story_beat/models/binder_document.dart';
import 'package:story_beat/models/binder_folder.dart';

import '../models/binder_item.dart';
import '../models/project.dart';
import '../models/trash_item.dart';
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

  Future<void> createDocument(BinderFolder folder, String filename) async {
    await _filesystem.createDocument(folder.path, filename);

    await refresh();
  }

  Future<void> createFolder(String folderName) async {
    if (_project == null) return;

    await _filesystem.createFolder(_project!.path, folderName);

    await refresh();
  }

  Future<void> renameItem(BinderItem item, String newName) async {
    final renamed = await _filesystem.renameItem(item, newName);

    await refresh();

    if (_selectedItem?.id == item.id) {
      _selectedItem = _findItemByPath(renamed.path);
      notifyListeners();
    }
  }

  Future<void> moveToTrash(BinderItem item) async {
    await _filesystem.moveToTrash(item);

    if (_selectedItem?.id == item.id || _containsItem(item, _selectedItem)) {
      _selectedItem = null;
    }

    await refresh();
  }

  Future<List<TrashItem>> listTrash() async {
    if (_project == null) return [];

    return _filesystem.listTrash(_project!.path);
  }

  Future<void> recoverTrashItem(TrashItem item) async {
    await _filesystem.recoverTrashItem(item);

    await refresh();
  }

  void startCreatingFolder() {
    if (_project == null) return;

    cancelCreateFolder();

    _binderItems = [
      ..._binderItems,
      const BinderFolder(
        id: '__new_folder__',
        name: '',
        path: '',
        isEditing: true,
      ),
    ];

    notifyListeners();
  }

  Future<void> startCreatingFile(BinderFolder folder) async {
    final index = _binderItems.indexWhere((e) => e.id == folder.id);

    if (index == -1) return;

    final updatedFolder = folder.copyWith(
      children: [
        ...folder.children,
        const BinderDocument(
          id: '__new__',
          name: '',
          path: '',
          isEditing: true,
        ),
      ],
    );

    _binderItems[index] = updatedFolder;

    notifyListeners();
  }

  void selectItem(BinderItem item) {
    _selectedItem = item;
    notifyListeners();
  }

  void cancelCreateDocument(BinderFolder folder) {
    folder.children.removeWhere(
      (item) => item is BinderDocument && item.isEditing,
    );

    notifyListeners();
  }

  void cancelCreateFolder() {
    _binderItems.removeWhere((item) => item is BinderFolder && item.isEditing);

    notifyListeners();
  }

  Future<void> refresh() async {
    if (_project == null) return;

    _binderItems = await _filesystem.loadBinder(_project!.path);

    notifyListeners();
  }

  BinderItem? _findItemByPath(String path) {
    for (final item in _binderItems) {
      if (item.path == path) {
        return item;
      }

      if (item is BinderFolder) {
        for (final child in item.children) {
          if (child.path == path) {
            return child;
          }
        }
      }
    }

    return null;
  }

  bool _containsItem(BinderItem item, BinderItem? candidate) {
    if (candidate == null || item is! BinderFolder) {
      return false;
    }

    return item.children.any((child) => child.id == candidate.id);
  }
}
