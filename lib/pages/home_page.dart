import 'package:flutter/material.dart';
import 'package:story_beat/controllers/project_controller.dart';
import 'package:story_beat/services/local_filesystem_service.dart';
import 'package:story_beat/widgets/editor_toolbar.dart';
import 'package:story_beat/widgets/status_bar.dart';

import '../widgets/app_toolbar.dart';
import '../widgets/binder_panel.dart';
import '../widgets/editor_panel.dart';
import '../widgets/inspector_panel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ProjectController controller;

  @override
  void initState() {
    super.initState();

    controller = ProjectController(filesystem: LocalFilesystemService());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final project = controller.project;
          final items = controller.binderItems;
          final selectedItem = controller.selectedItem;
          final isLoading = controller.isLoading;

          return Column(
            children: [
              AppToolbar(
                projectController: controller,
                project: project,
                isLoading: isLoading,
              ),

              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 260,
                      child: BinderPanel(
                        project: project,
                        items: items,
                        selectedItem: selectedItem,
                        isLoading: isLoading,
                        onItemSelected: controller.selectItem,
                        projectController: controller,
                      ),
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          EditorToolbar(),

                          Expanded(
                            child: EditorPanel(
                              project: project,
                              selectedItem: selectedItem,
                              isLoading: isLoading,
                            ),
                          ),

                          StatusBar(project: project, items: items),
                        ],
                      ),
                    ),

                    SizedBox(
                      width: 260,
                      child: InspectorPanel(
                        project: project,
                        selectedItem: selectedItem,
                        isLoading: isLoading,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
