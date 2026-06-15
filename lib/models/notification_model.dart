/// Notification type enum.
enum NotificationType {
  promotion,
  order,
  system,
  news;

  String get icon {
    switch (this) {
      case NotificationType.promotion:
        return '🎉';
      case NotificationType.order:
        return '📦';
      case NotificationType.system:
        return '⚙️';
      case NotificationType.news:
        return '📰';
    }
  }
}

/// Notification model.
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final String? route;
  final String? routeParam;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    this.route,
    this.routeParam,
    required this.createdAt,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    bool? isRead,
    String? route,
    String? routeParam,
    DateTime? createdAt,
  }) =>
      NotificationModel(
        id: id ?? this.id,
        title: title ?? this.title,
        body: body ?? this.body,
        type: type ?? this.type,
        isRead: isRead ?? this.isRead,
        route: route ?? this.route,
        routeParam: routeParam ?? this.routeParam,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type.name,
        'isRead': isRead,
        'route': route,
        'routeParam': routeParam,
        'createdAt': createdAt.toIso8601String(),
      };

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        type: NotificationType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => NotificationType.system,
        ),
        isRead: json['isRead'] as bool,
        route: json['route'] as String?,
        routeParam: json['routeParam'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
