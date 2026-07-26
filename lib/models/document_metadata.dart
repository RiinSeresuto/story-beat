class DocumentMetadata {
  final String title;
  final String status;
  final List<String> tags;
  final String synopsis;

  const DocumentMetadata({
    required this.title,
    this.status = 'Draft',
    this.tags = const [],
    this.synopsis = '',
  });

  DocumentMetadata copyWith({
    String? title,
    String? status,
    List<String>? tags,
    String? synopsis,
  }) {
    return DocumentMetadata(
      title: title ?? this.title,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      synopsis: synopsis ?? this.synopsis,
    );
  }
}
