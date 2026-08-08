import 'package:flutter/material.dart';
import 'package:story_beat/models/binder_item.dart';
import 'package:story_beat/models/project.dart';
import 'package:story_beat/theme/app_colors.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key, required this.project, required this.items});

  final Project? project;
  final List<BinderItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: Text(
        project == null
            ? "Open a folder to begin"
            : "${items.length} item${items.length == 1 ? '' : 's'}",
        textAlign: TextAlign.center,
      ),
    );
  }
}
