import 'package:flutter/material.dart';
import 'package:story_beat/models/binder_item.dart';
import 'package:story_beat/models/markdown_document.dart';
import 'package:story_beat/models/project.dart';
import 'package:story_beat/theme/app_colors.dart';
import 'package:super_editor/super_editor.dart';

class EditorPanel extends StatefulWidget {
  const EditorPanel({
    super.key,
    required this.project,
    required this.selectedItem,
    required this.isLoading,
    required this.markdownDocument,
    required this.editor,
  });

  final Project? project;
  final BinderItem? selectedItem;
  final bool isLoading;
  final MarkdownDocument? markdownDocument;
  final Editor? editor;

  @override
  State<EditorPanel> createState() => _EditorPanelState();
}

class _EditorPanelState extends State<EditorPanel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.project == null) {
      return const Center(
        child: Text(
          "Open a folder to start writing.",
          style: TextStyle(color: AppColors.text),
        ),
      );
    }

    final editor = widget.editor;

    if (editor == null) {
      return const Center(
        child: Text(
          "Select a document to start writing.",
          style: TextStyle(color: AppColors.text),
        ),
      );
    }

    return SuperEditor(
      editor: editor,
      componentBuilders: [
        TaskComponentBuilder(editor),
        ...defaultComponentBuilders,
      ],
      stylesheet: defaultStylesheet.copyWith(
        documentPadding: EdgeInsets.zero,
        inlineTextStyler: (attributions, existingStyle) {
          return defaultInlineTextStyler(attributions, existingStyle).copyWith(
            color: AppColors.text,
            fontSize: 18,
            height: 1.8,
          );
        },
      ),
    );
  }
}
