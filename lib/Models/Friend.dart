class Friend {
  final int idFriends;
  final int userId;
  final int friendsId;

  Friend({
    required this.idFriends,
    required this.userId,
    required this.friendsId,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      idFriends: json['idFriends'] ?? 0,
      userId: json['userId'] ?? 0,
      friendsId: json['friendsId'] ?? 0,
    );
  }
}
