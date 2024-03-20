import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:social_network/main.dart';

import '../Api/ApiRequest.dart';
import '../Models/Correspondence.dart';
import '../Models/MessageUser.dart';
import '../Chat/ChatScreen.dart';

class MessengerScreen extends StatefulWidget {
  @override
  _MessengerScreenState createState() => _MessengerScreenState();
}

class _MessengerScreenState extends State<MessengerScreen> {
  Set<int> uniqueSenderIds = {};
  List<Correspondence> correspondences = [];

  @override
  void initState() {
    super.initState();
    _fetchCorrespondences();
  }

  Future<String> _fetchUserName(int userId) async {
    try {
      final response = await Dio().get(
          '$api/Users/GetUserNameByUserId?userId=$userId');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        print('Failed to fetch username with status code: ${response
            .statusCode}');
      }
    } catch (error) {
      print('Error fetching username: $error');
    }

    return 'Unknown';
  }

  Future<List<int>> _fetchUserPhoto(int userId) async {
    try {
      final response = await Dio().get('$api/Users/user-photos/$userId',
          options: Options(responseType: ResponseType.bytes));

      if (response.statusCode == 200) {
        return response.data!;
      } else {
        print('Failed to fetch user photo with status code: ${response
            .statusCode}');
        return [
        ]; // or throw an exception if you want to handle errors differently
      }
    } catch (error) {
      print('Error: $error');
      return [
      ]; // or throw an exception if you want to handle errors differently
    }
  }


  Future<void> _fetchCorrespondences() async {
    try {
      final response = await Dio().get('$api/Correspondences');

      if (response.statusCode == 200) {
        final List<dynamic> correspondenceData = response.data;
        // Создаём временный список для новых корреспонденций
        final List<Correspondence> newCorrespondences = [];
        // Очищаем список уникальных ID отправителей, чтобы избежать дублирования
        uniqueSenderIds.clear();

        for (final correspondenceJson in correspondenceData) {
          final correspondence = Correspondence.fromJson(correspondenceJson);

          // Проверяем, что корреспонденция связана с текущим пользователем
          if (correspondence.userId == int.parse(IDUser)) {
            if (!uniqueSenderIds.contains(correspondence.senderId)) {
              final lastMessage = await _fetchLastMessage(correspondence.senderId);

              if (lastMessage != null) {
                correspondence.lastMessage = lastMessage;
                newCorrespondences.add(correspondence);
                // Добавляем ID отправителя в список уникальных ID
                uniqueSenderIds.add(correspondence.senderId);
              }
            }
          }
        }

        // Обновляем состояние списка корреспонденций новыми данными
        setState(() {
          correspondences = newCorrespondences;
        });
      } else {
        print('Failed to fetch correspondences with status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching correspondences: $error');
    }
  }


  Future<MessageUser?> _fetchLastMessage(int userId) async {
    try {
      final response = await Dio().get(
          '$api/MessageUsers/GetLastMessage/$userId');

      if (response.statusCode == 200) {
        final Map<String, dynamic> lastMessageJson = response.data;
        return MessageUser.fromJson(lastMessageJson);
      } else {
        print('Failed to fetch last message with status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching last message: $error');
    }

    return null;
  }

// Update your _fetchUserName method to fetch message text
  Future<String> _fetchUserNameAndMessageText(int userId, int messageId) async {
    try {
      final List<Response<dynamic>> responses = await Future.wait([
        Dio().get('$api/Users/GetUserNameByUserId?userId=$userId'),
        Dio().get('$api/MessageUsers/GetLastMessage/$userId'),
      ]);

      final userNameResponse = responses[0];
      final messageTextResponse = responses[1];

      if (userNameResponse.statusCode == 200) {
        final userName = userNameResponse.data;
        final messageText = messageTextResponse.data;
        return '$userName: $messageText';
      } else {
        print('Failed to fetch username with status code: ${userNameResponse
            .statusCode}');
      }
    } catch (error) {
      print('Error fetching username or message text: $error');
    }

    return 'Unknown';
  }

  List<int> userPhoto = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.deepOrangeAccent,
          title: Text('Мессенджер'),
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh, // Ваш метод обновления данных
          child: ListView.builder(
            itemCount: correspondences.length,
            itemBuilder: (context, index) {
              final correspondence = correspondences[index];
              final lastMessageText = correspondence.lastMessage?.textMessage ?? 'No messages';

              return FutureBuilder(
                future: Future.wait([
                  _fetchUserNameAndMessageText(correspondence.senderId, correspondence.messageId),
                  _fetchUserPhoto(correspondence.senderId),
                  _fetchUserName(correspondence.senderId),
                ]),
                builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                  ),
                  title: Text('Loading...'),
                  subtitle: Text('Last message: ${correspondence.messageId}'),
                );
              } else if (snapshot.hasError) {
                return ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                  ),
                  title: Text('Error: ${snapshot.error}'),
                  subtitle: Text('Last message: ${correspondence.messageId}'),
                );
              } else {
                final userNameAndMessageText = snapshot.data![0];
                userPhoto = snapshot.data![1] as List<int>;
                final userName = snapshot.data![2];

                return ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundImage: userPhoto.isNotEmpty ? MemoryImage(
                        Uint8List.fromList(userPhoto)) : null,
                  ),
                  title: Text(userName.toString()),
                  subtitle: Text(lastMessageText),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatScreen(
                              senderId: correspondence.userId,
                              recipientId: correspondence.senderId,
                              nameUser: '$userName',
                            ),
                      ),
                    );
                  },
                );
              }
            },
          );
        },
      ),
    )
    );
  }

  Future<void> _onRefresh() async {
    // Здесь должен быть ваш код для получения новых данных с сервера
    await _fetchCorrespondences();
  }
}