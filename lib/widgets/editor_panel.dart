import 'package:flutter/material.dart';
import 'package:story_beat/models/binder_item.dart';
import 'package:story_beat/models/project.dart';
import 'package:story_beat/theme/app_colors.dart';

class EditorPanel extends StatelessWidget {
  const EditorPanel({
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
    final currentProject = project;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border, width: 1.0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : project == null
          ? const Center(
              child: Text(
                "Open a folder to start writing.",
                style: TextStyle(color: AppColors.text),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedItem?.name ?? "No document selected",
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  selectedItem?.path ?? currentProject!.path,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                const Expanded(
                  child: TextField(
                    expands: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Start writing...",
                    ),
                    style: TextStyle(fontSize: 18, height: 1.8),
                    cursorWidth: 2,
                    cursorHeight: 24,
                    cursorColor: AppColors.text,
                  ),
                ),
              ],
            ),
    );
  }
}
