import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../Api/ApiRequest.dart';
import '../Models/Application.dart';
import '../Models/User.dart';
import 'UserProfile.dart'; // Подставьте путь к вашей модели User

class Applications extends StatefulWidget {
  const Applications({Key? key}) : super(key: key);

  @override
  State<Applications> createState() => _ApplicationsState();
}

class _ApplicationsState extends State<Applications> {
  List<Application> applications = [];

  @override
  void initState() {
    super.initState();
    getApplications();
  }

  Future<void> getApplications() async {
    try {
      final response = await Dio().get('$api/Applications');
      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData != null) {
          setState(() {
            applications = (responseData as List<dynamic>)
                .map((appJson) => Application.fromJson(appJson))
                .where((app) => app.recipientId == int.parse(IDUser))
                .toList();

            applications.sort((a, b) => a.senderId.compareTo(b.senderId));
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
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final application = applications[index];
          Future<List<int>> userPhotosFuture = _fetchUserPhotos(application.id);

          return FutureBuilder<User?>(
            future: getUserData(application.senderId),
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
                    title: Text('Не удалось получить данные пользователя'),
                  );
                }
              } else {
                return ListTile(
                  title: Text('Заявок нет'),
                );
              }
            },
          );
        },
      ),
    );
  }
}
