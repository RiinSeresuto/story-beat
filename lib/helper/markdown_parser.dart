import '../models/markdown_document.dart';

class MarkdownParser {
  static MarkdownDocument format(String content) {
    final regex = RegExp(r'^---\s*\n([\s\S]*?)\n---\s*\n?([\s\S]*)$');

    final match = regex.firstMatch(content);

    if (match == null) {
      return MarkdownDocument(frontMatter: {}, body: content);
    }

    final frontMatterText = match.group(1)!;
    final body = match.group(2) ?? '';

    final frontMatter = <String, dynamic>{};

    for (final line in frontMatterText.split('\n')) {
      final separator = line.indexOf(':');

      if (separator == -1) continue;

      final key = line.substring(0, separator).trim();
      final value = line.substring(separator + 1).trim();

      frontMatter[key] = value;
    }

    return MarkdownDocument(frontMatter: frontMatter, body: body);
  }
}
