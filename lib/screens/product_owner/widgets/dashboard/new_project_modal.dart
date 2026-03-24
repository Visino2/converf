import 'package:flutter/material.dart';
import 'package:converf/features/projects/models/project.dart';
import 'new_project/new_project_wizard.dart';

class NewProjectModal extends StatelessWidget {
  final Project? initialProject;

  const NewProjectModal({super.key, this.initialProject});

  @override
  Widget build(BuildContext context) {
    return NewProjectWizard(initialProject: initialProject);
  }
}
