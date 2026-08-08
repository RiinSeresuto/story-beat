import 'package:flutter/material.dart';
import 'package:story_beat/theme/app_colors.dart';

class EditorToolbar extends StatelessWidget {
  const EditorToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
      color: AppColors.background,
      child: Text(
        " H1  H2  B  I  ~~  []  ```  *  1.  Link",
        textAlign: TextAlign.center,
      ),
    );
  }
}
