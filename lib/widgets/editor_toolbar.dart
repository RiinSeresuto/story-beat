import 'package:flutter/material.dart';
import 'package:story_beat/controllers/project_controller.dart';
import 'package:story_beat/theme/app_colors.dart';

class EditorToolbar extends StatelessWidget {
  const EditorToolbar({super.key, required this.projectController});

  final ProjectController projectController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
      color: AppColors.background,
      child: Row(
        children: [
          Text(
            " H1  H2  B  I  ~~  []  ```  *  1.  Link",
            textAlign: TextAlign.center,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: projectController.closeDocument,
          ),
        ],
      ),
    );
  }
}
