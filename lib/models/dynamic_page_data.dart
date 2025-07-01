class DynamicPageData {
  final String id;
  final String title;
  final String content;
  final String type;
  final bool isActive;

  DynamicPageData({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    this.isActive = true,
  });

  factory DynamicPageData.fromJson(Map<String, dynamic> json) {
    return DynamicPageData(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      isActive: json['is_active'] == true || json['is_active'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'is_active': isActive,
    };
  }
}
