import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:story_beat/models/binder_document.dart';
import 'package:story_beat/models/binder_folder.dart';
import 'package:story_beat/services/local_filesystem_service.dart';

void main() {
  late Directory projectDirectory;
  late LocalFilesystemService filesystem;

  setUp(() async {
    projectDirectory = await Directory.systemTemp.createTemp(
      'story_beat_filesystem_test_',
    );
    filesystem = LocalFilesystemService();
  });

  tearDown(() async {
    if (await projectDirectory.exists()) {
      await projectDirectory.delete(recursive: true);
    }
  });

  test(
    'renameItem renames a document and keeps the markdown extension',
    () async {
      final folder = await Directory(
        p.join(projectDirectory.path, 'Drafts'),
      ).create();
      final file = await File(p.join(folder.path, 'Scene.md')).create();
      final document = BinderDocument(
        id: file.path,
        name: 'Scene',
        path: file.path,
        parentId: folder.path,
      );

      final renamed = await filesystem.renameItem(document, 'Opening.md');

      expect(renamed.path, p.join(folder.path, 'Opening.md'));
      expect(await File(renamed.path).exists(), isTrue);
      expect(await file.exists(), isFalse);
    },
  );

  test('renameItem rejects empty and conflicting names', () async {
    final folder = await Directory(
      p.join(projectDirectory.path, 'Drafts'),
    ).create();
    final file = await File(p.join(folder.path, 'Scene.md')).create();
    await File(p.join(folder.path, 'Opening.md')).create();
    final document = BinderDocument(
      id: file.path,
      name: 'Scene',
      path: file.path,
      parentId: folder.path,
    );

    expect(
      () => filesystem.renameItem(document, '   '),
      throwsA(isA<Exception>()),
    );
    expect(
      () => filesystem.renameItem(document, 'Opening'),
      throwsA(isA<Exception>()),
    );
  });

  test('renameItem renames a folder', () async {
    final folder = await Directory(
      p.join(projectDirectory.path, 'Drafts'),
    ).create();
    final binderFolder = BinderFolder(
      id: folder.path,
      name: 'Drafts',
      path: folder.path,
    );

    final renamed = await filesystem.renameItem(binderFolder, 'Scenes');

    expect(renamed.path, p.join(projectDirectory.path, 'Scenes'));
    expect(await Directory(renamed.path).exists(), isTrue);
    expect(await folder.exists(), isFalse);
  });

  test('moveToTrash hides documents and folders from loadBinder', () async {
    final folder = await Directory(
      p.join(projectDirectory.path, 'Drafts'),
    ).create();
    final file = await File(p.join(folder.path, 'Scene.md')).create();
    final document = BinderDocument(
      id: file.path,
      name: 'Scene',
      path: file.path,
      parentId: folder.path,
    );
    final binderFolder = BinderFolder(
      id: folder.path,
      name: 'Drafts',
      path: folder.path,
    );

    await filesystem.moveToTrash(document);

    var binder = await filesystem.loadBinder(projectDirectory.path);
    expect((binder.single as BinderFolder).children, isEmpty);

    await filesystem.moveToTrash(binderFolder);

    binder = await filesystem.loadBinder(projectDirectory.path);
    expect(binder, isEmpty);
    expect(
      await Directory(p.join(projectDirectory.path, '.binder_trash')).exists(),
      isTrue,
    );
  });

  test(
    'recoverTrashItem restores an item and removes it from manifest',
    () async {
      final folder = await Directory(
        p.join(projectDirectory.path, 'Drafts'),
      ).create();
      final file = await File(p.join(folder.path, 'Scene.md')).create();
      final document = BinderDocument(
        id: file.path,
        name: 'Scene',
        path: file.path,
        parentId: folder.path,
      );

      await filesystem.moveToTrash(document);
      final trash = await filesystem.listTrash(projectDirectory.path);

      await filesystem.recoverTrashItem(trash.single);

      expect(await File(file.path).exists(), isTrue);
      expect(await filesystem.listTrash(projectDirectory.path), isEmpty);
    },
  );

  test(
    'recoverTrashItem creates a recovered name when original path exists',
    () async {
      final folder = await Directory(
        p.join(projectDirectory.path, 'Drafts'),
      ).create();
      final file = await File(p.join(folder.path, 'Scene.md')).create();
      final document = BinderDocument(
        id: file.path,
        name: 'Scene',
        path: file.path,
        parentId: folder.path,
      );

      await filesystem.moveToTrash(document);
      await File(file.path).create();
      final trash = await filesystem.listTrash(projectDirectory.path);

      await filesystem.recoverTrashItem(trash.single);

      expect(await File(file.path).exists(), isTrue);
      expect(
        await File(p.join(folder.path, 'Scene recovered.md')).exists(),
        isTrue,
      );
    },
  );
}
