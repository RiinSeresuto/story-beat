import 'package:flutter/material.dart';
import 'package:story_beat/theme/app_colors.dart';

class BinderPanel extends StatelessWidget {
  const BinderPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: ListView(
        children: const [
          ListTile(title: Text("Novel"), textColor: AppColors.text),

          ListTile(
            contentPadding: EdgeInsets.only(left: 32),
            title: Text("Chapter 1"),
            textColor: AppColors.text,
          ),

          ListTile(
            contentPadding: EdgeInsets.only(left: 32),
            title: Text("Chapter 2"),
            textColor: AppColors.text,
          ),

          ListTile(title: Text("Notes"), textColor: AppColors.text),

          ListTile(
            contentPadding: EdgeInsets.only(left: 32),
            title: Text("Magic System"),
            textColor: AppColors.text,
          ),
        ],
      ),
    );
  }
}
