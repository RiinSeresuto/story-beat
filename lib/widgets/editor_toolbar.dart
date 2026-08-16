import 'package:flutter/material.dart';
import 'package:story_beat/controllers/project_controller.dart';
import 'package:story_beat/theme/app_colors.dart';
import 'package:super_editor/super_editor.dart';

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
          _ToolbarButton(
            tooltip: 'Paragraph',
            icon: Icons.notes,
            onPressed: () => projectController.setCurrentBlockType(null),
          ),
          _ToolbarButton(
            tooltip: 'Heading 1',
            label: 'H1',
            onPressed: () =>
                projectController.setCurrentBlockType(header1Attribution),
          ),
          _ToolbarButton(
            tooltip: 'Heading 2',
            label: 'H2',
            onPressed: () =>
                projectController.setCurrentBlockType(header2Attribution),
          ),
          const SizedBox(width: 8),
          _ToolbarButton(
            tooltip: 'Bold',
            icon: Icons.format_bold,
            onPressed: () =>
                projectController.toggleTextAttribution(boldAttribution),
          ),
          _ToolbarButton(
            tooltip: 'Italic',
            icon: Icons.format_italic,
            onPressed: () =>
                projectController.toggleTextAttribution(italicsAttribution),
          ),
          _ToolbarButton(
            tooltip: 'Strikethrough',
            icon: Icons.strikethrough_s,
            onPressed: () => projectController.toggleTextAttribution(
              strikethroughAttribution,
            ),
          ),
          _ToolbarButton(
            tooltip: 'Code',
            icon: Icons.code,
            onPressed: () =>
                projectController.toggleTextAttribution(codeAttribution),
          ),
          const SizedBox(width: 8),
          _ToolbarButton(
            tooltip: 'Bulleted list',
            icon: Icons.format_list_bulleted,
            onPressed: () =>
                projectController.setCurrentListType(ListItemType.unordered),
          ),
          _ToolbarButton(
            tooltip: 'Numbered list',
            icon: Icons.format_list_numbered,
            onPressed: () =>
                projectController.setCurrentListType(ListItemType.ordered),
          ),
          const Spacer(),
          _ToolbarButton(
            tooltip: 'Back to binder',
            icon: Icons.arrow_back,
            onPressed: () => projectController.closeDocument(),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.tooltip,
    required this.onPressed,
    this.icon,
    this.label,
  });

  final String tooltip;
  final IconData? icon;
  final String? label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: icon == null
            ? Text(
                label!,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w700,
                ),
              )
            : Icon(icon, color: AppColors.text),
        onPressed: onPressed,
      ),
    );
  }
}
