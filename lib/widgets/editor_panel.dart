import 'package:flutter/material.dart';
import 'package:story_beat/theme/app_colors.dart';

class EditorPanel extends StatelessWidget {
  const EditorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border, width: 1.0),
        borderRadius: BorderRadius.circular(8),
      ),

      child: const TextField(
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
    );
  }
}
