import 'MessageUser.dart';

class Correspondence {
  final int idCorrespondence;
  final int messageId;
  final int userId;
  final int senderId;
  MessageUser? lastMessage; // Add this property

  Correspondence({
    required this.idCorrespondence,
    required this.messageId,
    required this.userId,
    required this.senderId,
    this.lastMessage, // Initialize it with null
  });

 /* factory Correspondence.fromJson(Map<String, dynamic> json) {
    return Correspondence(
      idCorrespondence: json['idCorrespondence'],
      messageId: json['messageId'],
      userId: json['userId'],
      senderId: json['senderId'],
    );
  }*/

  Map<String, dynamic> toJson() {
    return {
      'idCorrespondence': idCorrespondence,
      'messageId': messageId,
      'userId': userId,
      'senderId': senderId,
      // Include lastMessage details if it's not null
      'lastMessage': lastMessage?.toJson(),
    };
  }

  factory Correspondence.fromJson(Map<String, dynamic> json) {
    // Your existing fromJson constructor
    // Modify it to handle lastMessage
    return Correspondence(
      idCorrespondence: json['idCorrespondence'],
      messageId: json['messageId'],
      userId: json['userId'],
      senderId: json['senderId'],
      lastMessage: json['lastMessage'] != null ? MessageUser.fromJson(json['lastMessage']) : null,
    );
  }
}
