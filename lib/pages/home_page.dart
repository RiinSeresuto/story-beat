import 'package:flutter/material.dart';

import '../widgets/binder_panel.dart';
import '../widgets/editor_panel.dart';
import '../widgets/inspector_panel.dart';
import '../widgets/toolbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppToolbar(),

          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 260, child: BinderPanel()),

                const Expanded(
                  child: Column(
                    children: [
                      Text(
                        " H1  H2  B  I  ~~  []  "
                        "  ```  •  1.  Link",
                      ),
                      Expanded(child: EditorPanel()),
                      Text("100,000 words"),
                    ],
                  ),
                ),

                const SizedBox(width: 260, child: InspectorPanel()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
