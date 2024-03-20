import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Api/ApiRequest.dart';
import '../Models/Friend.dart';
import '../Models/User.dart';
import 'UserProfile.dart';

class PageFriends extends StatefulWidget {
  const PageFriends({Key? key}) : super(key: key);

  @override
  State<PageFriends> createState() => _PageFriendsState();
}

class _PageFriendsState extends State<PageFriends> {
  List<Friend> friends = [];

  @override
  void initState() {
    super.initState();
    getFriends();
  }

  Future<void> getFriends() async {
    try {
      final response = await Dio().get('$api/Friends'); // Убедитесь, что здесь правильный путь к вашим друзьям
      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData != null) {
          setState(() {
            friends = (responseData as List<dynamic>)
                .map((friendJson) => Friend.fromJson(friendJson))
                .where((friend) => friend.userId == int.parse(IDUser))
                .toList();
          });
        } else {
          print('Error: Response data is null');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<User?> getUserData(int userId) async {
    try {
      final response = await Dio().get('$api/Users/$userId');
      if (response.statusCode == 200) {
        final userJson = response.data;
        return User.fromJson(userJson);
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error: $error');
      return null;
    }
  }

  Future<List<int>> _fetchUserPhotos(int userID) async {
    try {
      final Dio _dio = Dio();
      _dio.options.responseType = ResponseType.bytes;
      Response<List<int>> response = await _dio.get('$api/Users/user-photos/$userID');

      if (response.statusCode == 200) {
        return response.data!;
      } else {
        print('Failed to fetch user photos with status code: ${response.statusCode}');
        return []; // or throw an exception if you want to handle errors differently
      }
    } catch (error) {
      print('Error: $error');
      return []; // or throw an exception if you want to handle errors differently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          Future<List<int>> userPhotosFuture = _fetchUserPhotos(friend.friendsId);

          return FutureBuilder<User?>(
            future: getUserData(friend.friendsId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data != null) {
                  final user = snapshot.data!;
                  return ListTile(
                    leading: FutureBuilder<List<int>>(
                      future: _fetchUserPhotos(user.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
                            String initials = user.firstName.isNotEmpty ? user.firstName[0] : '';
                            initials += user.lastName.isNotEmpty ? user.lastName[0] : '';
                            return CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey,
                              child: Text(
                                initials,
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          } else {
                            return CircleAvatar(
                              radius: 20,
                              backgroundImage: MemoryImage(Uint8List.fromList(snapshot.data!)),
                            );
                          }
                        } else {
                          return CircleAvatar(radius: 20, backgroundColor: Colors.grey);
                        }
                      },
                    ),
                    title: Text('${user.firstName} ${user.lastName}'),
                    subtitle: Text('@${user.loginUser}'),
                    onTap: () {
                      userPhotosFuture.then((userPhotos) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfile(
                              firstName: user.firstName,
                              lastName: user.lastName,
                              login: user.loginUser,
                              userPhoto: userPhotos.isNotEmpty ? Uint8List.fromList(userPhotos) : null,
                              recipientId: user.id,
                              senderId: int.parse(IDUser),
                            ),
                          ),
                        );
                      });
                    },
                    // Добавьте другие детали заявки, если необходимо
                  );
                } else {
                  return ListTile(
                    title: Text('Не удалось получить данные пользователя друга'),
                  );
                }
              } else {
                return ListTile(
                  title: Text('Загрузка...'),
                );
              }
            },
          );
        },
      ),
    );
  }
}