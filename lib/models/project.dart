class Project {
  final String title;
  final String path;

  const Project({required this.title, required this.path});

  @override
  String toString() {
    return 'Project(title: $title, path: $path)';
  }
}
