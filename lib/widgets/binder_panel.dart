import 'package:flutter/material.dart';

import '../models/binder_document.dart';
import '../models/binder_folder.dart';
import '../models/binder_item.dart';
import '../models/project.dart';
import '../theme/app_colors.dart';

class BinderPanel extends StatelessWidget {
  const BinderPanel({
    super.key,
    required this.project,
    required this.items,
    required this.selectedItem,
    required this.isLoading,
    required this.onItemSelected,
  });

  final Project? project;
  final List<BinderItem> items;
  final BinderItem? selectedItem;
  final bool isLoading;
  final ValueChanged<BinderItem> onItemSelected;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        color: AppColors.background,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (project == null) {
      return Container(
        color: AppColors.background,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              "Open a folder to see its binder.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.text),
            ),
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return Container(
        color: AppColors.background,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              "This folder has no binder items yet.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.text),
            ),
          ),
        ),
      );
    }

    return Container(
      color: AppColors.background,
      child: ListView(
        children: [
          for (final item in items) ...[
            if (item is BinderFolder) ...[
              _buildFolder(item),

              for (final child in item.children)
                if (child is BinderDocument) _buildDocument(child),
            ] else if (item is BinderDocument)
              _buildDocument(item),
          ],
        ],
      ),
    );
  }

  Widget _buildFolder(BinderFolder folder) {
    final selected = selectedItem?.id == folder.id;

    return Material(
      color: AppColors.background,
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
        onTap: () => onItemSelected(folder),
      ),
    );
  }

  Widget _buildDocument(BinderDocument document) {
    final selected = selectedItem?.id == document.id;

    return Material(
      color: AppColors.background,
      child: ListTile(
        dense: true,
        minTileHeight: 28,
        selected: selected,
        selectedTileColor: AppColors.surface,
        contentPadding: const EdgeInsets.only(left: 36, right: 12),
        leading: const Icon(
          Icons.article_outlined,
          size: 16,
          color: AppColors.text,
        ),
        title: Text(
          document.name,
          style: const TextStyle(color: AppColors.text, fontSize: 12),
        ),
        onTap: () => onItemSelected(document),
      ),
    );
  }
}
