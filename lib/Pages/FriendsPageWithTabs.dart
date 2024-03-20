import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Api/ApiRequest.dart';
import 'AllUsers.dart';
import 'Applications.dart';
import 'PageFriends.dart';

class FriendsPageWithTabs extends StatefulWidget {
  @override
  _FriendsPageWithTabsState createState() => _FriendsPageWithTabsState();
}

class _FriendsPageWithTabsState extends State<FriendsPageWithTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Пользователи'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _SearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab, // Устанавливаем индикатор на всю ширину вкладки
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.0),
                  color: Colors.deepOrangeAccent,
                ),
                labelColor: Colors.white,

                labelStyle: TextStyle(fontSize: 12),
                unselectedLabelColor: Colors.deepOrangeAccent,
                tabs: [
                  Tab(text: 'Друзья'),
                  Tab(text: 'Пользователи'),
                  Tab(text: 'Заявки'),
                ],
              ),

            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                PageFriends(),
                AllUsers(),
                Applications(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Вызывается при завершении поиска и нажатии на результат поиска.
    // Можете вернуть соответствующий виджет с результатами.
    return Container();
  }

  Future<List<int>> _fetchUserPhotos(int userID) async {
    try {
      final Dio _dio = Dio();
      _dio.options.responseType = ResponseType.bytes;
      Response<List<int>> response =
      await _dio.get('$api/Users/user-photos/$userID');

      if (response.statusCode == 200) {
        return response.data!;
      } else {
        print(
            'Failed to fetch user photos with status code: ${response.statusCode}');
        return []; // or throw an exception if you want to handle errors differently
      }
    } catch (error) {
      print('Error: $error');
      return []; // or throw an exception if you want to handle errors differently
    }
  }


  @override
  Widget buildSuggestions(BuildContext context) {
    // Вызывается при вводе текста в поле поиска.
    // Можете вернуть соответствующий виджет с предложениями поиска.
    final suggestionList = query.isEmpty
        ? [] // Пустой список, если поисковый запрос пуст
        : users
        .where((user) =>
    user.firstName.toLowerCase().contains(query.toLowerCase()) ||
        user.lastName.toLowerCase().contains(query.toLowerCase()) ||
        user.loginUser.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final user = suggestionList[index];
        return ListTile(
          contentPadding: EdgeInsets.all(8.0),
          // Adjust padding as needed
          leading: FutureBuilder<List<int>>(
            future: _fetchUserPhotos(user.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError ||
                    snapshot.data == null ||
                    snapshot.data!.isEmpty) {
                  // Если произошла ошибка или изображение отсутствует, отобразите первые две буквы пользователя
                  String initials =
                  user.firstName.isNotEmpty ? user.firstName[0] : '';
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
                    backgroundImage:
                    MemoryImage(Uint8List.fromList(snapshot.data!)),
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
            // Действие, выполняемое при выборе результата поиска
            close(context, user.firstName);
          },
        );
      },
    );
  }
}
