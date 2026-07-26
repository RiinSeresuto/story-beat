import 'package:flutter/material.dart';
import 'package:story_beat/theme/app_colors.dart';

class InspectorPanel extends StatelessWidget {
  const InspectorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Inspector",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),

          SizedBox(height: 24),

          Text("Title"),
          Text("Chapter 1"),

          SizedBox(height: 16),

          Text("Words"),
          Text("0"),

          SizedBox(height: 16),

          Text("Status"),
          Text("Draft"),

          SizedBox(height: 16),

          Text("Modified"),
          Text("Today"),
        ],
      ),
    );
  }
}
