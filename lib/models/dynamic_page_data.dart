// Simple model for dynamic page data
class DynamicPageData {
  final String title;
  final String content;
  final String description;
  final String id;

  DynamicPageData({
    required this.title,
    required this.content,
    required this.description,
    required this.id,
  });

  factory DynamicPageData.fromJson(Map<String, dynamic> json) {
    return DynamicPageData(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      description: json['description'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'description': description,
      'id': id,
    };
  }
}
