import 'package:social_network/Models/MessageFile.dart';

class MessageUser {
  final int? id;
  final String textMessage;
  final DateTime sendingTime;
  final int userId;
  final int senderId;
  final List<MessageFile> messageFiles; // Обновленное поле

  MessageUser({
    this.id,
    required this.textMessage,
    required this.sendingTime,
    required this.userId,
    required this.senderId,
    this.messageFiles = const [], // Инициализация пустым списком
  });

  factory MessageUser.fromJson(Map<String, dynamic> json) {
    // Проверка на null и создание пустого списка, если 'messageFiles' отсутствует или null
    List<MessageFile> files = (json['messageFiles'] as List?)?.map((v) => MessageFile.fromJson(v)).toList() ?? [];

    return MessageUser(
      id: json['idMessage'],
      textMessage: json['textMessage'],
      sendingTime: DateTime.parse(json['sendingTime']),
      userId: json['userId'],
      senderId: json['senderId'],
      messageFiles: files, // Теперь files гарантированно не null
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'textMessage': textMessage,
      'sendingTime': sendingTime.toIso8601String(),
      'userId': userId,
      'senderId': senderId,
      'messageFiles': messageFiles.map((v) => v.toJson()).toList(),
    };
  }
}
