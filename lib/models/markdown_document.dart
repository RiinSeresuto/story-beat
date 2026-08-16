class MarkdownDocument {
  final Map<String, dynamic> frontMatter;
  final String body;

  const MarkdownDocument({required this.frontMatter, required this.body});

  String toMarkdown({String? body}) {
    final content = body ?? this.body;

    if (frontMatter.isEmpty) {
      return content;
    }

    final metadata = frontMatter.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');

    return '---\n$metadata\n---\n$content';
  }
}
