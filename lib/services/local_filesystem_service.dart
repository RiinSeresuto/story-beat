import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import '../models/binder_document.dart';
import '../models/binder_folder.dart';
import '../models/binder_item.dart';
import '../models/project.dart';
import '../models/trash_item.dart';
import 'filesystem_service.dart';

class LocalFilesystemService implements FilesystemService {
  static const _trashFolderName = '.binder_trash';
  static const _trashItemsFolderName = 'items';
  static const _manifestFileName = '.manifest.json';

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
                parentId: entity.path,
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

  @override
  Future<BinderItem> renameItem(BinderItem item, String newName) async {
    final cleanName = _cleanName(newName, isDocument: item.isDocument);
    final directory = p.dirname(item.path);
    final extension = item.isDocument ? '.md' : '';
    final newPath = p.join(directory, '$cleanName$extension');

    if (p.equals(item.path, newPath)) {
      return item;
    }

    if (await FileSystemEntity.type(newPath) != FileSystemEntityType.notFound) {
      throw Exception('A binder item with that name already exists.');
    }

    if (item.isFolder) {
      final renamed = await Directory(item.path).rename(newPath);
      return BinderFolder(
        id: renamed.path,
        name: cleanName,
        path: renamed.path,
        parentId: item.parentId,
      );
    }

    final renamed = await File(item.path).rename(newPath);
    return BinderDocument(
      id: renamed.path,
      name: cleanName,
      path: renamed.path,
      parentId: item.parentId,
    );
  }

  @override
  Future<void> moveToTrash(BinderItem item) async {
    final projectPath = _projectPathFor(item);
    final trashItemsDirectory = Directory(
      p.join(projectPath, _trashFolderName, _trashItemsFolderName),
    );
    await trashItemsDirectory.create(recursive: true);

    final targetPath = await _uniqueTrashPath(
      trashItemsDirectory.path,
      p.basename(item.path),
    );

    if (item.isFolder) {
      await Directory(item.path).rename(targetPath);
    } else {
      await File(item.path).rename(targetPath);
    }

    final manifest = await _readManifest(projectPath);
    manifest.add(
      TrashItem(
        originalPath: item.path,
        trashPath: targetPath,
        name: item.name,
        isFolder: item.isFolder,
        trashedAt: DateTime.now(),
      ),
    );
    await _writeManifest(projectPath, manifest);
  }

  @override
  Future<List<TrashItem>> listTrash(String projectPath) async {
    final manifest = await _readManifest(projectPath);
    final existingItems = <TrashItem>[];

    for (final item in manifest) {
      if (await FileSystemEntity.type(item.trashPath) !=
          FileSystemEntityType.notFound) {
        existingItems.add(item);
      }
    }

    if (existingItems.length != manifest.length) {
      await _writeManifest(projectPath, existingItems);
    }

    existingItems.sort((a, b) => b.trashedAt.compareTo(a.trashedAt));
    return existingItems;
  }

  @override
  Future<void> recoverTrashItem(TrashItem item) async {
    final projectPath = _projectPathForTrashItem(item);
    final destinationPath = await _recoverDestinationPath(item);

    await Directory(p.dirname(destinationPath)).create(recursive: true);

    if (item.isFolder) {
      await Directory(item.trashPath).rename(destinationPath);
    } else {
      await File(item.trashPath).rename(destinationPath);
    }

    final manifest = await _readManifest(projectPath);
    manifest.removeWhere((entry) => entry.trashPath == item.trashPath);
    await _writeManifest(projectPath, manifest);
  }

  String _cleanName(String value, {required bool isDocument}) {
    var cleanName = value.trim();

    if (isDocument && cleanName.toLowerCase().endsWith('.md')) {
      cleanName = cleanName.substring(0, cleanName.length - 3).trim();
    }

    if (cleanName.isEmpty) {
      throw Exception('Name cannot be empty.');
    }

    if (p.basename(cleanName) != cleanName) {
      throw Exception('Name cannot contain path separators.');
    }

    return cleanName;
  }

  String _projectPathFor(BinderItem item) {
    if (item.isFolder) {
      return p.dirname(item.path);
    }

    if (item.parentId != null) {
      return p.dirname(item.parentId!);
    }

    return p.dirname(item.path);
  }

  String _projectPathForTrashItem(TrashItem item) {
    var directory = p.dirname(item.trashPath);

    if (p.basename(directory) == _trashItemsFolderName) {
      directory = p.dirname(directory);
    }

    if (p.basename(directory) == _trashFolderName) {
      return p.dirname(directory);
    }

    return p.dirname(item.originalPath);
  }

  Future<String> _uniqueTrashPath(String directoryPath, String basename) async {
    var candidate = p.join(
      directoryPath,
      '${DateTime.now().microsecondsSinceEpoch}_$basename',
    );
    var index = 2;

    while (await FileSystemEntity.type(candidate) !=
        FileSystemEntityType.notFound) {
      candidate = p.join(
        directoryPath,
        '${DateTime.now().microsecondsSinceEpoch}_${index}_$basename',
      );
      index += 1;
    }

    return candidate;
  }

  Future<String> _recoverDestinationPath(TrashItem item) async {
    if (await FileSystemEntity.type(item.originalPath) ==
        FileSystemEntityType.notFound) {
      return item.originalPath;
    }

    final directory = p.dirname(item.originalPath);
    final extension = item.isFolder ? '' : p.extension(item.originalPath);
    final baseName = item.isFolder
        ? p.basename(item.originalPath)
        : p.basenameWithoutExtension(item.originalPath);

    var candidate = p.join(directory, '$baseName recovered$extension');
    var index = 2;

    while (await FileSystemEntity.type(candidate) !=
        FileSystemEntityType.notFound) {
      candidate = p.join(directory, '$baseName recovered $index$extension');
      index += 1;
    }

    return candidate;
  }

  File _manifestFile(String projectPath) {
    return File(p.join(projectPath, _trashFolderName, _manifestFileName));
  }

  Future<List<TrashItem>> _readManifest(String projectPath) async {
    final file = _manifestFile(projectPath);

    if (!await file.exists()) {
      return [];
    }

    final decoded = jsonDecode(await file.readAsString());

    if (decoded is! List) {
      return [];
    }

    return decoded
        .whereType<Map>()
        .map((item) => TrashItem.fromJson(Map<String, Object?>.from(item)))
        .toList();
  }

  Future<void> _writeManifest(String projectPath, List<TrashItem> items) async {
    final file = _manifestFile(projectPath);
    await file.parent.create(recursive: true);

    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(
      encoder.convert(items.map((e) => e.toJson()).toList()),
    );
  }
}
