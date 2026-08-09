import 'package:flutter/material.dart';
import 'package:story_beat/models/binder_item.dart';
import 'package:story_beat/models/markdown_document.dart';
import 'package:story_beat/models/project.dart';
import 'package:story_beat/theme/app_colors.dart';

class EditorPanel extends StatefulWidget {
  const EditorPanel({
    super.key,
    required this.project,
    required this.selectedItem,
    required this.isLoading,
    required this.markdownDocument,
  });

  final Project? project;
  final BinderItem? selectedItem;
  final bool isLoading;
  final MarkdownDocument? markdownDocument;

  @override
  State<EditorPanel> createState() => _EditorPanelState();
}

class _EditorPanelState extends State<EditorPanel> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(
      text: widget.markdownDocument?.body ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant EditorPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update the editor when a different document is selected.
    if (oldWidget.selectedItem?.id != widget.selectedItem?.id) {
      _textController.text = widget.markdownDocument?.body ?? '';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _textController,
            expands: true,
            maxLines: null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Start writing...",
            ),
            style: const TextStyle(fontSize: 18, height: 1.8),
            cursorWidth: 2,
            cursorHeight: 24,
            cursorColor: AppColors.text,
          ),
        ),
      ],
    );
  }
}
