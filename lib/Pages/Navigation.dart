import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_network/Pages/Friends.dart';
import 'package:social_network/Pages/News.dart';

import '../Api/ApiRequest.dart';
import '../Models/User.dart';
import 'AllUsers.dart';
import 'Applications.dart';
import 'FriendsPageWithTabs.dart';
import 'Messages.dart';
import 'PageFriends.dart';
import 'Profile.dart';
import '../Provider/AnimatedBottomNavigationBar.dart';
import '../Provider/CustomTabBar.dart';
import 'package:responsive_builder/responsive_builder.dart';


class NavigationScreen extends StatefulWidget {
  final User user;

  NavigationScreen({required this.user});

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen>
    with SingleTickerProviderStateMixin {
  static bool anOtherMenuActive = false;
  late TabController _tabController;

  late User user; // Используем "late" для отложенной инициализации

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initUserDataFromSharedPreferences();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }



  Future<void> _initUserDataFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;
    final String firstName = prefs.getString('firstName') ?? '';
    final String lastName = prefs.getString('lastName') ?? '';
    final String loginUser = prefs.getString('loginUser') ?? '';

    user = User(
      id: userId,
      firstName: firstName,
      lastName: lastName,
      loginUser: loginUser,
    );

    setState(() {});
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return NewsScreen();
      case 1:
        return MessengerScreen();
      case 2:
        return UserDetailsWidget();
      case 3:
        return FriendsScreen();
      default:
        return NewsScreen(); // Можете вернуть пустой контейнер или другой экран по умолчанию
    }
  }
  Widget _getSelectedScreenWEB() {
    switch (_selectedIndex) {
      case 0:
        return UserDetailsWidget();
      case 1:
        return NewsScreen();
      case 2:
        return MessengerScreen();
      case 3:
        return FriendsScreen();
      default:
        return NewsScreen(); // Можете вернуть пустой контейнер или другой экран по умолчанию
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildWebLayout(),
      desktop: _buildWebLayout(),
    );
  }

  @override
  Widget _buildMobileLayout()  {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.deepOrangeAccent, // Цвет фона статус-бара
      statusBarIconBrightness: Brightness.light, // Цвет иконок статус-бара
    ));
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          NewsScreen(),
          MessengerScreen(),
          UserDetailsWidget(),
          FriendsPageWithTabs(), // Используйте новый виджет для страницы "Друзья"
        ],
      ),
      floatingActionButton: (!anOtherMenuActive)
          ? CustomFloatingNavBar(
        currentIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }


  Widget _buildWebLayout() {
    return Row(
      children: [
        // Боковая навигация
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          labelType: NavigationRailLabelType.selected,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.person),
              label: Text('Профиль'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.article),
              label: Text('Новости'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.message),
              label: Text('Мессенджер'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.group),
              label: Text('Друзья'),
            ),
          ],
        ),
        // Основной контент
        Expanded(
          child: Scaffold(
            appBar: _selectedIndex == 3
                ? AppBar(
              title: Text('Друзья'),
              automaticallyImplyLeading: false,
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'Друзья'),
                  Tab(text: 'Все пользователи'),
                  Tab(text: 'Заявки'),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      // Отобразите диалоговое окно поиска
                      showSearch(
                        context: context,
                        delegate: _SearchDelegate(),
                      );
                    },
                  ),
                ),
              ],
            )
                : null,
            body: _selectedIndex == 3
                ? TabBarView(
              controller: _tabController,
              children: [
                PageFriends(),
                AllUsers(),
                Applications(),
              ],
            )
                : _getSelectedScreenWEB(),
            // Используем метод для определения выбранного экрана
            backgroundColor: Colors.grey[900],
          ),
        ),
      ],
    );
  }



/*
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: _selectedIndex == 3 ? AppBar(
           title: Text('Друзья'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Друзья'),
              Tab(text: 'Все пользователи'),
              Tab(text: 'Заявки'),
            ],
          ),
        ) : null,
        body: _selectedIndex == 3
            ? TabBarView(
          children: [
            PageFriends(),
            AllUsers(),
            Applications(),
          ],
        )
            : _screens[_selectedIndex],
        bottomNavigationBar: (!anOtherMenuActive)
            ? ClipRRect(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.grey[900],
              selectedItemColor: Colors.deepOrangeAccent,
              unselectedItemColor: Colors.white,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.article),
                  label: 'Новости',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.message),
                  label: 'Мессенджер',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Профиль',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group),
                  label: 'Друзья',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedIconTheme:
              const IconThemeData(color: Colors.deepOrangeAccent),
              unselectedIconTheme:
              const IconThemeData(color: Colors.white),
            ),
          ),
        )
            : null,
        backgroundColor: Colors.grey[900],
      ),
    );
  }*/
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
