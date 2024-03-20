import 'package:social_network/Api/ApiRequest.dart';

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String loginUser;
  // Другие поля, конструктор и методы, если необходимо.

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.loginUser,
  });

  // Добавьте конструктор fromJson для разбора данных JSON.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['idUser'] ?? IDUser, // Если 'idUser' равно null, используем значение по умолчанию (например, 0).
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      loginUser: json['loginUser'] ?? '',
      // И другие поля, если необходимо.
    );
  }
}
