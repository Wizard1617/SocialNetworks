  import 'dart:typed_data';

  import 'package:dio/dio.dart';
  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';

  import '../Api/ApiRequest.dart';
  import '../Models/User.dart';
  import 'Profile.dart';
import 'UserProfile.dart';

  class AllUsers extends StatefulWidget {
    const AllUsers({Key? key}) : super(key: key);

    @override
    State<AllUsers> createState() => _AllUsersState();
  }
  List<User> users = [];
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
  
  class _AllUsersState extends State<AllUsers> {
    List<User> filteredUsers = []; // Создайте новый список для отфильтрованных пользователей
    TextEditingController searchController = TextEditingController();
    @override
    void initState() {
      super.initState();
      getUsers();
    }

    Future<void> getUsers() async {
      try {
        final response = await Dio().get('$api/Users');
        print(response);
        if (response.statusCode == 200) {
          setState(() {
            users = (response.data as List<dynamic>)
                .map((userJson) => User.fromJson(userJson))
                .toList();
            filteredUsers = List.from(users); // Инициализируйте filteredUsers данными из users
          });
        } else {
          print('Error: ${response.statusCode}');
        }
      } catch (error) {
        print('Error: $error');
      }
    }


    void filterUsers(String query) {
      setState(() {
        filteredUsers = users
            .where((user) =>
        user.firstName.toLowerCase().contains(query.toLowerCase()) ||
            user.lastName.toLowerCase().contains(query.toLowerCase()) ||
            user.loginUser.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: ListView.builder(
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final user = filteredUsers[index];
            Future<List<int>> userPhotosFuture = _fetchUserPhotos(user.id);
            return ListTile(
              contentPadding: EdgeInsets.all(8.0), // Adjust padding as needed
              leading: FutureBuilder<List<int>>(
                future: _fetchUserPhotos(user.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
                      // Если произошла ошибка или изображение отсутствует, отобразите первые две буквы пользователя
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
                      // Если изображение успешно загружено, используйте MemoryImage
                      return CircleAvatar(
                        radius: 20,
                        backgroundImage: MemoryImage(Uint8List.fromList(snapshot.data!)),
                      );
                    }
                  } else {
                    // Пока идет загрузка, отобразите заглушку (можете использовать индикатор загрузки)
                    return CircleAvatar(radius: 20, backgroundColor: Colors.grey);
                  }
                },
              ),

              title: Text('${user.firstName} ${user.lastName}'),
              subtitle: Text('@${user.loginUser}'),
              onTap: () {
                userPhotosFuture.then((userPhotos) {
                  if (user.id == int.parse(IDUser)) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetailsWidget(
                          user: User(
                            id: user.id,
                            firstName: user.firstName,
                            lastName: user.lastName,
                            loginUser: user.loginUser,
                            // Добавьте другие поля, если необходимо.
                          ),
                        ),
                      ),
                    );
                  } else {
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
                  }

                });
              },

            );
          },
        )
      );
    }
  }
