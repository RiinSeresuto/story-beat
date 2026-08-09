import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:story_beat/controllers/project_controller.dart';

import '../models/binder_document.dart';
import '../models/binder_folder.dart';
import '../models/binder_item.dart';
import '../models/project.dart';
import '../models/trash_item.dart';
import '../theme/app_colors.dart';

class BinderPanel extends StatelessWidget {
  const BinderPanel({
    super.key,
    required this.project,
    required this.items,
    required this.selectedItem,
    required this.isLoading,
    required this.onItemSelected,
    required this.projectController,
  });

  final Project? project;
  final List<BinderItem> items;
  final BinderItem? selectedItem;
  final bool isLoading;
  final ValueChanged<BinderItem> onItemSelected;
  final ProjectController projectController;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (project == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            "Open a folder to see its binder.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.text),
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      "This folder has no binder items yet.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.text),
                    ),
                  ),
                )
              : ListView(
                  children: [
                    for (final item in items) ...[
                      if (item is BinderFolder) ...[
                        _buildFolder(context, item),

                        for (final child in item.children)
                          if (child is BinderDocument)
                            _buildDocument(
                              context: context,
                              folder: item,
                              document: child,
                            ),
                      ],
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (details) {
        _showHeaderMenu(context, details.globalPosition);
      },
      child: SizedBox(
        height: 36,
        child: Row(
          children: [
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text(
                  "Binder",
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: "Add folder",
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 36, height: 36),
              onPressed: projectController.startCreatingFolder,
              icon: const Icon(
                Icons.create_new_folder_outlined,
                size: 18,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolder(BuildContext context, BinderFolder folder) {
    if (folder.isEditing) {
      return _buildFolderEditor(folder);
    }

    final selected = selectedItem?.id == folder.id;

    return GestureDetector(
      onSecondaryTapDown: (details) {
        _showItemMenu(context, details.globalPosition, folder);
      },
      child: Material(
        color: AppColors.background,
        child: Row(
          children: [
            Expanded(
              child: ListTile(
                dense: true,
                minTileHeight: 28,
                selected: selected,
                selectedTileColor: AppColors.surface,
                contentPadding: const EdgeInsets.only(left: 12, right: 12),
                leading: const Icon(
                  Icons.folder_outlined,
                  size: 16,
                  color: AppColors.text,
                ),
                title: Text(
                  folder.name,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            IconButton(
              tooltip: "Add document",
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 36, height: 28),
              onPressed: () {
                projectController.startCreatingFile(folder);
              },
              icon: const Icon(
                Icons.post_add_sharp,
                size: 16,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderEditor(BinderFolder folder) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12),
      child: Focus(
        onKeyEvent: (_, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            projectController.cancelCreateFolder();
            return KeyEventResult.handled;
          }

          return KeyEventResult.ignored;
        },
        child: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Folder name",
            border: InputBorder.none,
            isDense: true,
          ),
          onTapOutside: (_) {
            projectController.cancelCreateFolder();
          },
          onSubmitted: (value) async {
            if (value.trim().isEmpty) {
              projectController.cancelCreateFolder();
              return;
            }

            await projectController.createFolder(value);
          },
        ),
      ),
    );
  }

  Widget _buildDocument({
    required BuildContext context,
    BinderFolder? folder,
    required BinderDocument document,
    double leftPadding = 36,
  }) {
    if (document.isEditing) {
      return Padding(
        padding: const EdgeInsets.only(left: 36, right: 12),
        child: Focus(
          onKeyEvent: (_, event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.escape) {
              if (folder != null) {
                projectController.cancelCreateDocument(folder);
              }
              return KeyEventResult.handled;
            }

            return KeyEventResult.ignored;
          },
          child: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Document name",
              border: InputBorder.none,
              isDense: true,
            ),
            onTapOutside: (_) {
              if (folder != null) {
                projectController.cancelCreateDocument(folder);
              }
            },
            onSubmitted: (value) async {
              if (value.trim().isEmpty) {
                if (folder != null) {
                  projectController.cancelCreateDocument(folder);
                }
                return;
              }

              if (folder != null) {
                await projectController.createDocument(folder, value);
              }
            },
          ),
        ),
      );
    }

    final selected = selectedItem?.id == document.id;

    return GestureDetector(
      onSecondaryTapDown: (details) {
        _showItemMenu(context, details.globalPosition, document);
      },
      child: Material(
        color: AppColors.background,
        child: ListTile(
          dense: true,
          minTileHeight: 28,
          selected: selected,
          selectedTileColor: AppColors.surface,
          contentPadding: EdgeInsets.only(left: leftPadding, right: 12),
          leading: const Icon(
            Icons.article_outlined,
            size: 16,
            color: AppColors.text,
          ),
          title: Text(
            document.name,
            style: const TextStyle(color: AppColors.text, fontSize: 12),
          ),
          onTap: () => projectController.selectItem(document),
        ),
      ),
    );
  }

  Future<void> _showHeaderMenu(
    BuildContext context,
    Offset globalPosition,
  ) async {
    final action = await showMenu<String>(
      context: context,
      position: _menuPosition(context, globalPosition),
      items: const [
        PopupMenuItem(
          value: 'recover',
          child: ListTile(
            dense: true,
            leading: Icon(Icons.restore_from_trash_outlined),
            title: Text('Recover...'),
          ),
        ),
      ],
    );

    if (action == 'recover' && context.mounted) {
      await _showRecoverDialog(context);
    }
  }

  Future<void> _showItemMenu(
    BuildContext context,
    Offset globalPosition,
    BinderItem item,
  ) async {
    final action = await showMenu<String>(
      context: context,
      position: _menuPosition(context, globalPosition),
      items: const [
        PopupMenuItem(
          value: 'rename',
          child: ListTile(
            dense: true,
            leading: Icon(Icons.drive_file_rename_outline),
            title: Text('Rename'),
          ),
        ),
        PopupMenuItem(
          value: 'trash',
          child: ListTile(
            dense: true,
            leading: Icon(Icons.delete_outline),
            title: Text('Move to Trash'),
          ),
        ),
      ],
    );

    if (!context.mounted) return;

    switch (action) {
      case 'rename':
        await _renameItem(context, item);
        break;
      case 'trash':
        await _moveToTrash(context, item);
        break;
    }
  }

  RelativeRect _menuPosition(BuildContext context, Offset globalPosition) {
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;

    return RelativeRect.fromRect(
      Rect.fromPoints(globalPosition, globalPosition),
      Offset.zero & overlay.size,
    );
  }

  Future<void> _renameItem(BuildContext context, BinderItem item) async {
    final newName = await _showRenameDialog(context, item);

    if (newName == null || newName.trim().isEmpty) {
      return;
    }

    try {
      await projectController.renameItem(item, newName);
    } catch (error) {
      if (context.mounted) {
        _showError(context, error);
      }
    }
  }

  Future<String?> _showRenameDialog(
    BuildContext context,
    BinderItem item,
  ) async {
    return showDialog<String>(
      context: context,
      builder: (context) => _RenameBinderItemDialog(item: item),
    );
  }

  Future<void> _moveToTrash(BuildContext context, BinderItem item) async {
    try {
      await projectController.moveToTrash(item);
    } catch (error) {
      if (context.mounted) {
        _showError(context, error);
      }
    }
  }

  Future<void> _showRecoverDialog(BuildContext context) async {
    final trashItems = await projectController.listTrash();

    if (!context.mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recover from Trash'),
          content: SizedBox(
            width: 360,
            child: trashItems.isEmpty
                ? const Text('Trash is empty.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: trashItems.length,
                    itemBuilder: (context, index) {
                      final item = trashItems[index];

                      return ListTile(
                        dense: true,
                        leading: Icon(
                          item.isFolder
                              ? Icons.folder_outlined
                              : Icons.article_outlined,
                        ),
                        title: Text(item.name),
                        subtitle: Text(_trashSubtitle(item)),
                        trailing: TextButton(
                          onPressed: () async {
                            await _recoverItem(context, item);
                          },
                          child: const Text('Recover'),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _trashSubtitle(TrashItem item) {
    final type = item.isFolder ? 'Folder' : 'Document';
    final date = item.trashedAt.toLocal().toString().split('.').first;

    return '$type - $date';
  }

  Future<void> _recoverItem(BuildContext context, TrashItem item) async {
    try {
      await projectController.recoverTrashItem(item);

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (context.mounted) {
        _showError(context, error);
      }
    }
  }

  void _showError(BuildContext context, Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
    );
  }
}

class _RenameBinderItemDialog extends StatefulWidget {
  const _RenameBinderItemDialog({required this.item});

  final BinderItem item;

  @override
  State<_RenameBinderItemDialog> createState() =>
      _RenameBinderItemDialogState();
}

class _RenameBinderItemDialogState extends State<_RenameBinderItemDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.item.name);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return AlertDialog(
      title: Text('Rename ${item.isFolder ? 'folder' : 'document'}'),
      content: TextField(
        autofocus: true,
        controller: _controller,
        decoration: InputDecoration(
          labelText: item.isFolder ? 'Folder name' : 'Document name',
        ),
        onSubmitted: (value) {
          Navigator.of(context).pop(value);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Rename'),
        ),
      ],
    );
  }
}
