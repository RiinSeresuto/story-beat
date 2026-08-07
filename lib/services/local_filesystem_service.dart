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
  Future<String> createDocument(String folderPath, String filename) async {
    final cleanName = filename.trim();

    if (cleanName.isEmpty) {
      throw Exception("Filename cannot be empty.");
    }

    final file = File(p.join(folderPath, "$cleanName.md"));

    if (await file.exists()) {
      throw Exception("A document with that name already exists.");
    }

    await file.create();

    return file.path;
  }

  @override
  Future<String> createFolder(String projectPath, String folderName) async {
    final cleanName = folderName.trim();

    if (cleanName.isEmpty) {
      throw Exception("Folder name cannot be empty.");
    }

    final directory = Directory(p.join(projectPath, cleanName));

    if (await directory.exists()) {
      throw Exception("A folder with that name already exists.");
    }

    await directory.create();

    return directory.path;
  }

  @override
  Future<String> renameDocument(String oldPath, String newName) async {
    final directory = p.dirname(oldPath);

    final newPath = p.join(directory, '$newName.md');

    final renamed = await File(oldPath).rename(newPath);

    return renamed.path;
  }
}
