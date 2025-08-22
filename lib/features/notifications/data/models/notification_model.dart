class NotificationModel {
  final String time;
  final String message;
  final bool isHighlighted;

  NotificationModel({
    required this.time,
    required this.message,
    this.isHighlighted = false,
  });
}