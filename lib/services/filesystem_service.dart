import '../models/project.dart';
import '../models/binder_item.dart';

abstract class FilesystemService {
  Future<Project?> openProject();

  Future<List<BinderItem>> loadBinder(String projectPath);

  Future<String> readDocument(String path);

  Future<void> saveDocument(String path, String content);
}
