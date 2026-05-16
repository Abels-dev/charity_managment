class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAtIso,
    this.readAtIso,
  });

  final String id;
  final String title;
  final String body;
  final String createdAtIso;
  final String? readAtIso;

  bool get isRead => readAtIso != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'createdAtIso': createdAtIso,
      'readAtIso': readAtIso,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAtIso: json['createdAtIso'] as String,
      readAtIso: json['readAtIso'] as String?,
    );
  }
}
