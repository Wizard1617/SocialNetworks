class Application {
  final int id;
  final int recipientId;
  final int senderId;

  Application({
    required this.id,
    required this.recipientId,
    required this.senderId,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['idApplications'] ?? 0, // Значение по умолчанию или выберите другое подходящее значение
      recipientId: json['recipientId'] ?? 0,
      senderId: json['senderId'] ?? 0,
    );
  }
}
