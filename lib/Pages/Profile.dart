import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_network/Models/NewsDto.dart';
import 'package:social_network/Pages/AchievementsTab.dart';
import 'package:social_network/Pages/AddNewsPage.dart';

import '../Api/ApiRequest.dart';
import '../Models/User.dart';
import 'Auth.dart';
import 'NewsDetailsScreen.dart';
import '../Provider/SettingsPage.dart';
import '../main.dart';

class UserDetailsWidget extends StatefulWidget {
  final User? user;

  const UserDetailsWidget({Key? key, this.user}) : super(key: key);

  @override
  _UserDetailsWidgetState createState() => _UserDetailsWidgetState();
}

List<Image> photoImages = [];

class _UserDetailsWidgetState extends State<UserDetailsWidget>
    with AutomaticKeepAliveClientMixin {
  // Другие части вашего класса остаются без изменений

  @override
  bool get wantKeepAlive => true;

  List<Uint8List> photoAllImages = [];
  List<NewsDto> newsData = []; // Добавляем здесь
  bool isDataLoaded = false;

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _getUserInfoFromPrefs();
    if (!isDataLoaded) {
      UserInfo();
    }
  }

  void UserInfo() {
    _fetchUserPhotos();
    _fetchUserNews();
    setState(() {
      isDataLoaded = true;
    });
  }

  Future<void> _getUserInfoFromPrefs() async {
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
      // Добавьте остальные поля пользователя
    );

    setState(() {});
  }

/*
  void _showNewsDetails(Map<String, dynamic> newsData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsListScreen(newsList: [newsData]),
      ),
    );
  }
*/

  Future<void> uploadUserPhoto(int userId, File imageFile) async {
    try {
      final List<int> bytes = imageFile.readAsBytesSync();

      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: 'user_photo.jpg'),
      });

      Response response = await dio.post(
        '$api/Users/upload-photo/$userId',
        data: formData,
      );

      if (response.statusCode == 200) {
        print('Фото успешно загружено. ID фото: ${response.data['photoID']}');
        // Обновите список фотографий с сервера или выполните другие действия
      } else {
        print('Ошибка при загрузке фото: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при загрузке фото: $e');
    }
  }

  Future<void> _selectImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final croppedImage = await _cropImage(pickedImage.path);

      if (croppedImage != null) {
        setState(() {
          final image = Image.file(croppedImage, fit: BoxFit.cover);
          photoImages.add(image);
        });

        // Теперь загрузите обрезанное фото на сервер и обновите логику загрузки
        await uploadUserPhoto(int.parse(IDUser), croppedImage);
      }
    }
  }

  Future<File?> _cropImage(String imagePath) async {
    final imageCropper = ImageCropper();

    final croppedImage = await imageCropper.cropImage(
      sourcePath: imagePath,
      aspectRatio: CropAspectRatio(
        ratioX: 1, // 1:1 aspect ratio
        ratioY: 1,
      ),
      compressQuality: 100,
      // Compression quality
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.deepOrange,
        // Цвет панели инструментов
        toolbarWidgetColor: Colors.white,
        // Цвет иконок на панели инструментов
        statusBarColor: Colors.deepOrange,
        // Цвет статус-бара
        backgroundColor: Colors.white, // Цвет фона обрезки
      ),
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0,
        aspectRatioLockDimensionSwapEnabled: false,
      ),
    );

    return croppedImage;
  }

  Future<void> _fetchUserPhotos() async {
    try {
      final Dio _dio = Dio();
      _dio.options.responseType = ResponseType.bytes;
      Response<List<int>> response =
          await _dio.get('$api/Users/user-photos/$IDUser');
      if (response.statusCode == 200) {
        final photoData = response.data;
        setState(() {
          final image = Image.memory(Uint8List.fromList(photoData!));
          photoImages.add(image);
        });
      } else {
        // Обработка ошибки
        print(
            'Failed to fetch user photos with status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> _selectImages() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final croppedImage = await _cropImage(pickedImage.path);

      if (croppedImage != null) {
        final imageBytes = await croppedImage.readAsBytes();

        setState(() {
          photoAllImages.add(Uint8List.fromList(imageBytes));
        });

        // Now, upload the cropped image to the server and update the upload logic
        await uploadUserPhotos(int.parse(IDUser), croppedImage);
        _fetchUserPhotoses();
      }
    }
  }

  Future<void> _fetchUserPhotoses() async {
    try {
      print('Fetching user photos...');

      final Dio _dio = Dio();
      _dio.options.responseType = ResponseType.json;
      Response response = await _dio.get('$api/Users/user-photoses/$IDUser');

      if (response.statusCode == 200) {
        final photos = response.data;
        List<Uint8List> images = []; // Change the type to Uint8List

        for (var photoData in photos) {
          final photoDataBytes = base64.decode(photoData);
          images.add(Uint8List.fromList(photoDataBytes));
          print('Added an image to the list');
        }

        setState(() {
          photoAllImages.clear();
          photoAllImages.addAll(images);
        });
      } else {
        // Handle error
        print(
            'Failed to fetch user photos with status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> uploadUserPhotos(int userId, File imageFile) async {
    try {
      final List<int> bytes = imageFile.readAsBytesSync();

      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: 'user_photo.jpg'),
      });

      Response response = await dio.post(
        '$api/Users/upload-photos/$userId',
        data: formData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Adjust this part based on the actual response structure
        if (responseData.containsKey('photoID')) {
          print('Фото успешно загружено. ID фото: ${responseData['photoID']}');
          // Обновите список фотографий с сервера или выполните другие действия
        } else {
          print('Ошибка при загрузке фото: Неверный формат ответа');
        }
      } else {
        print('Ошибка при загрузке фото: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при загрузке фото: $e');
    }
  }

  Future<Image> _fetchPicture(String? pictureId) async {
    try {
      final Dio _dio = Dio();
      _dio.options.responseType = ResponseType.bytes;
      Response<List<int>> response = await _dio.get('$api/Pictures/$pictureId');
      if (response.statusCode == 200) {
        final photoData = response.data;
        final image = Image.memory(Uint8List.fromList(photoData!));
        return image;
      } else {
        // Обработка ошибки
        print(
            'Failed to fetch picture data with status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching picture data: $error');
    }

    // Если изображение не найдено, вернуть пустой контейнер или другое запасное изображение
    return Image.asset('assets/images/placeholder_image.jpg');
  }

  Future<void> _fetchUserNews() async {
    try {
      final Dio _dio = Dio();
      _dio.options.responseType = ResponseType.json;
      Response response = await _dio.get('$api/Users/user-news/$IDUser');
      print('Response data: ${response.data}'); // Логирование ответа сервера
      if (response.statusCode == 200) {
        final newsListJson = response.data as List;
        List<NewsDto> newsList =
            newsListJson.map((json) => NewsDto.fromJson(json)).toList();
        setState(() {
          this.newsData = newsList; // Обновляем список новостей типа NewsDto
          isDataLoaded = true; // Обновляем флаг загрузки данных
        });
      } else {
        print(
            'Failed to fetch user news with status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching user news: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.deepOrangeAccent, // Цвет фона статус-бара
      statusBarIconBrightness: Brightness.light, // Цвет иконок статус-бара
    ));

    return SafeArea(
        child: DefaultTabController(
            length: 2, // Общее количество вкладок
            child: Scaffold(
              appBar: AppBar(
                title: Text("Профиль"),
                backgroundColor: Colors.deepOrangeAccent,
                actions: [
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text('Добавить публикацию'),
                        value: 'addNews',
                      ),
                      PopupMenuItem(
                        child: Text('Настройки'),
                        value: 'settings',
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'addNews') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddNews()),
                        );
                      } else if (value == 'settings') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Settings()),
                        );
                      }
                    },
                    shape: RoundedRectangleBorder(
                      // Добавляет закругленные углы
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ],
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  // Вызовите здесь функции для обновления данных
                  await _fetchUserPhotos();
                  await _fetchUserNews();
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  // Обеспечивает возможность прокрутки
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: _selectImage,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[700],
                          ),
                          child: ClipOval(
                            child: photoImages.isNotEmpty
                                ? photoImages.last
                                : Icon(Icons.add_a_photo),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        user.lastName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '@${user.loginUser}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),

                      TabBar(
                        tabs: [
                          Tab(text: "Фотографии"),
                          Tab(text: "Достижения"),
                        ],
                        indicatorColor: Colors.deepOrangeAccent,
                        labelColor: Colors.grey[700],
                        unselectedLabelColor: Colors.grey[700],
                      ),
                      // Важно: Container для TabBarView с фиксированной высотой, чтобы избежать ошибок рендеринга
                      Container(
                        height: 400, // Задайте подходящую высоту
                        child: TabBarView(
                          key: PageStorageKey<String>('newsListKey'),
                          children: [
                            // Вкладка Фотографии
                            GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 2,
                                mainAxisSpacing: 2,
                              ),
                              itemCount: newsData.length,
                              itemBuilder: (BuildContext context, int index) {
                                final newsItem =
                                    newsData[index]; // Получаем объект NewsDto
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NewsListScreen(
                                            newsList:
                                                newsData), // Передаем список новостей
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(0),
                                    child: CachedNetworkImage(
                                      imageUrl: "$api/Pictures/${newsItem.pictureId}",
                                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                      fit: BoxFit.cover,
                                    ),

                                  ),
                                );
                              },
                            ),

                            // Вкладка Достижения
                            AchievementsTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
        )
    );
  }
}
