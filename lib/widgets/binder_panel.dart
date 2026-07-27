import 'package:flutter/material.dart';
import 'package:story_beat/models/binder_item.dart';
import 'package:story_beat/models/project.dart';
import 'package:story_beat/theme/app_colors.dart';

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
    return Container(
      color: AppColors.background,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : project == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "Open a folder to see its binder.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.text),
                ),
              ),
            )
          : items.isEmpty
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
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                final selected = selectedItem?.id == item.id;

                return ListTile(
                  selected: selected,
                  selectedTileColor: AppColors.surface,
                  contentPadding: EdgeInsets.only(
                    left: item.isFolder ? 16 : 32,
                    right: 16,
                  ),
                  leading: Icon(
                    item.isFolder
                        ? Icons.folder_outlined
                        : Icons.article_outlined,
                    size: 18,
                    color: AppColors.text,
                  ),
                  title: Text(
                    item.name,
                    style: const TextStyle(color: AppColors.text),
                  ),
                  subtitle: Text(
                    item.isFolder ? "Folder" : "Document",
                    style: const TextStyle(color: AppColors.text, fontSize: 11),
                  ),
                  onTap: () => onItemSelected(item),
                );
              },
            ),
    );
  }
}
