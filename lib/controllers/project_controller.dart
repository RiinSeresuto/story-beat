import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:story_beat/helper/markdown_parser.dart';
import 'package:story_beat/models/binder_document.dart';
import 'package:story_beat/models/binder_folder.dart';
import 'package:story_beat/models/markdown_document.dart';
import 'package:super_editor/super_editor.dart';

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

  MarkdownDocument? _markdownDocument;

  MutableDocument? _editorDocument;
  MutableDocumentComposer? _editorComposer;
  Editor? _editor;
  Timer? _saveTimer;

  Project? get project => _project;
  List<BinderItem> get binderItems => List.unmodifiable(_binderItems);
  BinderItem? get selectedItem => _selectedItem;
  bool get isLoading => _loading;
  MarkdownDocument? get markdownDocument => _markdownDocument;
  MutableDocument? get editorDocument => _editorDocument;
  MutableDocumentComposer? get editorComposer => _editorComposer;
  Editor? get editor => _editor;

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

  Future<void> selectItem(BinderItem item) async {
    await saveCurrentDocument();

    _disposeEditor();

    _selectedItem = item;

    if (item is BinderDocument) {
      final content = await _filesystem.readDocument(item.path);

      _markdownDocument = MarkdownParser.format(content);

      _editorDocument = _documentFromMarkdown(_markdownDocument!.body);

      _editorDocument!.addListener(_scheduleSave);

      _editorComposer = MutableDocumentComposer();

      _editor = createDefaultDocumentEditor(
        document: _editorDocument!,
        composer: _editorComposer!,
        isHistoryEnabled: true,
      );
    } else {
      _markdownDocument = null;
    }

    notifyListeners();
  }

  Future<void> closeDocument() async {
    await saveCurrentDocument();

    _disposeEditor();

    _selectedItem = null;
    _markdownDocument = null;

    notifyListeners();
  }

  Future<void> saveCurrentDocument() async {
    final selectedItem = _selectedItem;
    final markdownDocument = _markdownDocument;
    final editorDocument = _editorDocument;

    if (selectedItem is! BinderDocument ||
        markdownDocument == null ||
        editorDocument == null) {
      return;
    }

    _saveTimer?.cancel();

    final markdown = _documentToMarkdown(editorDocument);

    await _filesystem.saveDocument(
      selectedItem.path,
      markdownDocument.toMarkdown(body: markdown),
    );
  }

  void _scheduleSave(_) {
    _saveTimer?.cancel();

    _saveTimer = Timer(const Duration(milliseconds: 500), saveCurrentDocument);
  }

  MutableDocument _documentFromMarkdown(String markdown) {
    final lines = markdown.split('\n');

    final nodes = <DocumentNode>[];

    for (final line in lines) {
      nodes.add(
        ParagraphNode(id: Editor.createNodeId(), text: AttributedText(line)),
      );
    }

    // SuperEditor needs at least one node.
    if (nodes.isEmpty) {
      nodes.add(
        ParagraphNode(id: Editor.createNodeId(), text: AttributedText('')),
      );
    }

    return MutableDocument(nodes: nodes);
  }

  String _documentToMarkdown(MutableDocument document) {
    final buffer = StringBuffer();

    var index = 0;

    while (true) {
      final node = document.getNodeAt(index);

      if (node == null) {
        break;
      }

      if (node is TextNode) {
        buffer.write(node.text.toPlainText());
      }

      if (document.getNodeAt(index + 1) != null) {
        buffer.writeln();
      }

      index++;
    }

    return buffer.toString();
  }

  void toggleTextAttribution(Attribution attribution) {
    final selection = _editorComposer?.selection;
    final editor = _editor;
    final document = _editorDocument;

    if (selection == null || editor == null || document == null) {
      return;
    }

    editor.execute([
      ToggleTextAttributionsRequest(
        documentRange: selection.normalize(document),
        attributions: {attribution},
      ),
    ]);
  }

  void setCurrentBlockType(Attribution? blockType) {
    final selection = _editorComposer?.selection;
    final editor = _editor;
    final document = _editorDocument;

    if (selection == null || editor == null || document == null) {
      return;
    }

    if (selection.base.nodeId != selection.extent.nodeId) {
      return;
    }

    final node = document.getNodeById(selection.extent.nodeId);

    if (node is ListItemNode) {
      editor.execute([
        ReplaceNodeRequest(
          existingNodeId: node.id,
          newNode: ParagraphNode(
            id: node.id,
            text: node.text,
            metadata: blockType == null ? {} : {'blockType': blockType},
          ),
        ),
      ]);

      return;
    }

    if (node is ParagraphNode) {
      editor.execute([
        ChangeParagraphBlockTypeRequest(nodeId: node.id, blockType: blockType),
      ]);
    }
  }

  void setCurrentListType(ListItemType type) {
    final selection = _editorComposer?.selection;
    final editor = _editor;
    final document = _editorDocument;

    if (selection == null || editor == null || document == null) {
      return;
    }

    if (selection.base.nodeId != selection.extent.nodeId) {
      return;
    }

    final node = document.getNodeById(selection.extent.nodeId);

    if (node is TextNode) {
      editor.execute([
        ReplaceNodeRequest(
          existingNodeId: node.id,
          newNode: ListItemNode(id: node.id, itemType: type, text: node.text),
        ),
      ]);
    }
  }

  void _disposeEditor() {
    _saveTimer?.cancel();

    _editorDocument?.removeListener(_scheduleSave);

    _editorComposer?.dispose();

    _editorDocument = null;
    _editorComposer = null;
    _editor = null;
  }

  @override
  void dispose() {
    _disposeEditor();
    super.dispose();
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
