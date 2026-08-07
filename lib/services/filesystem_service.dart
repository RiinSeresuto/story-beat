import '../models/project.dart';
import '../models/binder_item.dart';

abstract class FilesystemService {
  Future<Project?> openProject();

  Future<List<BinderItem>> loadBinder(String projectPath);

  Future<String> readDocument(String path);

  Future<void> saveDocument(String path, String content);

  Future<String> createDocument(String folderPath, String filename);

  Future<String> createFolder(String projectPath, String folderName);

  Future<String> renameDocument(String oldPath, String newName);
}
