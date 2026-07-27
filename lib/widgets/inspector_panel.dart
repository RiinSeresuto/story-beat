import 'package:flutter/material.dart';
import 'package:story_beat/models/binder_item.dart';
import 'package:story_beat/models/project.dart';
import 'package:story_beat/theme/app_colors.dart';

class InspectorPanel extends StatelessWidget {
  const InspectorPanel({
    super.key,
    required this.project,
    required this.selectedItem,
    required this.isLoading,
  });

  final Project? project;
  final BinderItem? selectedItem;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Inspector",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.text,
                  ),
                ),

                const SizedBox(height: 24),

                const Text("Project", style: TextStyle(color: AppColors.text)),
                Text(
                  project?.title ?? "No folder open",
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  project?.path ?? "Open a folder to load project details.",
                  style: const TextStyle(color: AppColors.text, fontSize: 12),
                ),

                const SizedBox(height: 16),

                const Text("Selection", style: TextStyle(color: AppColors.text)),
                Text(
                  selectedItem?.name ?? "Nothing selected",
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  selectedItem == null
                      ? "Choose a binder item to inspect it."
                      : (selectedItem!.isFolder ? "Folder" : "Document"),
                  style: const TextStyle(color: AppColors.text, fontSize: 12),
                ),

                const SizedBox(height: 16),

                const Text("Path", style: TextStyle(color: AppColors.text)),
                Text(
                  selectedItem?.path ?? "-",
                  style: const TextStyle(color: AppColors.text),
                ),
              ],
            ),
    );
  }
}
