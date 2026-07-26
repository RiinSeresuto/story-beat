import 'package:flutter/material.dart';
import 'package:story_beat/theme/app_colors.dart';

class AppToolbar extends StatelessWidget {
  const AppToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.background,
      child: Row(
        children: [
          const Text(
            "Freewrite Clone",
            style: TextStyle(color: AppColors.text),
          ),

          const Spacer(),

          TextButton(onPressed: () {}, child: const Text("Open")),

          TextButton(onPressed: () {}, child: const Text("Save")),
        ],
      ),
    );
  }
}
