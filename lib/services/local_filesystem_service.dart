import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import '../models/binder_document.dart';
import '../models/binder_folder.dart';
import '../models/binder_item.dart';
import '../models/project.dart';
import 'filesystem_service.dart';

class LocalFilesystemService implements FilesystemService {
  @override
  Future<Project?> openProject() async {
    final path = await FilePicker.getDirectoryPath();

    if (path == null) return null;

    return Project(title: p.basename(path), path: path);
  }

  @override
  Future<List<BinderItem>> loadBinder(String projectPath) async {
    final rootDirectory = Directory(projectPath);

    final items = <BinderItem>[];

    for (final entity in rootDirectory.listSync()) {
      final name = p.basename(entity.path);

      if (name.startsWith('.')) {
        continue;
      }

      if (entity is Directory) {
        final children = <BinderItem>[];

        for (final child in entity.listSync()) {
          final childName = p.basename(child.path);

          if (childName.startsWith('.')) {
            continue;
          }

          if (child is File && child.path.endsWith('.md')) {
            children.add(
              BinderDocument(
                id: child.path,
                name: p.basenameWithoutExtension(child.path),
                path: child.path,
              ),
            );
          }
        }

        items.add(
          BinderFolder(
            id: entity.path,
            name: name,
            path: entity.path,
            children: children,
          ),
        );

        continue;
      }

      if (entity is File && entity.path.endsWith('.md')) {
        items.add(
          BinderDocument(
            id: entity.path,
            name: p.basenameWithoutExtension(entity.path),
            path: entity.path,
          ),
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

  @override
  Future<String> createDocument(String folderPath) async {
    var counter = 1;

    while (true) {
      final filename = counter == 1 ? 'Untitled.md' : 'Untitled $counter.md';

      final fullPath = p.join(folderPath, filename);

      final file = File(fullPath);

      if (!await file.exists()) {
        await file.create(recursive: true);
        return fullPath;
      }

      counter++;
    }
  }

  @override
  Future<String> renameDocument(String oldPath, String newName) async {
    final directory = p.dirname(oldPath);

    final newPath = p.join(directory, '$newName.md');

    final renamed = await File(oldPath).rename(newPath);

    return renamed.path;
  }
}
