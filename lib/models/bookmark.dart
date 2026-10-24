
enum BookmarkType {
  website,
  github,
}

class Bookmark {
  final String id;
  final String title;
  final String url;
  final List<String> categories;
  final BookmarkType type;
  final String? previewImageUrl;
  final String? description;

  const Bookmark({
    required this.id,
    required this.title,
    required this.url,
    required this.categories,
    required this.type,
    this.previewImageUrl,
    this.description,
  });
}
