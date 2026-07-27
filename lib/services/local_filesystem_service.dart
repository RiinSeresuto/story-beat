import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../models/project.dart';
import '../models/binder_item.dart';
import '../models/binder_document.dart';
import '../models/binder_folder.dart';
import 'filesystem_service.dart';

class LocalFilesystemService implements FilesystemService {
  @override
  Future<Project?> openProject() async {
    final path = await FilePicker.getDirectoryPath();

    if (path == null) return null;

    return Project(title: path.split(Platform.pathSeparator).last, path: path);
  }

  @override
  Future<List<BinderItem>> loadBinder(String projectPath) async {
    final directory = Directory(projectPath);

    final items = <BinderItem>[];

    for (final entity in directory.listSync()) {
      final name = entity.uri.pathSegments.last;

      if (entity is Directory) {
        items.add(BinderFolder(id: entity.path, name: name, path: entity.path));
      } else if (entity is File && entity.path.endsWith('.md')) {
        items.add(
          BinderDocument(id: entity.path, name: name, path: entity.path),
        );
      }
    }

    return items;
  }

  @override
  Future<String> readDocument(String path) async {
    return File(path).readAsString();
  }

  @override
  Future<void> saveDocument(String path, String content) async {
    await File(path).writeAsString(content);
  }
}
