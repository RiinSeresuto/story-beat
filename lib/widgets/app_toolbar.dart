import 'package:flutter/material.dart';
import 'package:story_beat/controllers/project_controller.dart';
import 'package:story_beat/models/project.dart';
import 'package:story_beat/theme/app_colors.dart';

class AppToolbar extends StatelessWidget {
  const AppToolbar({
    super.key,
    required this.projectController,
    required this.project,
    required this.isLoading,
  });

  final ProjectController projectController;
  final Project? project;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.background,
      child: Row(
        children: [
          const Text(
            "Story Beat",
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          if (project != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    project!.title,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    project!.path,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Text(
                "No folder open",
                style: TextStyle(color: AppColors.text),
              ),
            ),

          TextButton(
            onPressed: isLoading
                ? null
                : () async {
                    await projectController.openProject();
                  },
            child: Text(isLoading ? "Opening..." : "Open"),
          ),

          TextButton(onPressed: () {}, child: const Text("Save")),
        ],
      ),
    );
  }
}
