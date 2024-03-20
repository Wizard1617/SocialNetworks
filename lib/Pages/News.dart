import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_network/Models/NewsDto.dart';

import '../Api/ApiRequest.dart';
import '../Models/NewsService.dart';
import '../Models/PictureService.dart';

class NewsScreen extends StatefulWidget {

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  final NewsService _newsService = NewsService();
  final PictureService _pictureService = PictureService();
  late List<Map<String, dynamic>> pictData = [];

  Map<String, Image> _imageCache = {};
  Map<int, List<int>> _userPhotoCache = {};


  final ScrollController _scrollController = ScrollController();
  List<NewsDto> newsData = [];
  int currentPage = 1;
  bool isLoading = false;
  bool isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    // Вызываем _fetchNewsData() только если данные еще не загружены
    if (!isDataLoaded) {
      _fetchNewsData();
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Вызываем _fetchNewsData() только если данные еще не загружены
    if (!isDataLoaded) {
      _fetchNewsData();
    }
  }


  Future<void> _fetchNewsData() async {
    if (isLoading) return;
    isLoading = true;
    try {
      List<NewsDto> newNews = await _newsService.getNews(pageNumber: currentPage, pageSize: 10);
      setState(() {
        newsData.addAll(newNews);
        currentPage++;
        isLoading = false;
        isDataLoaded = true;
      });
    } catch (error) {
      print('Error fetching news data: $error');
    }
  }


  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchNewsData();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Не забудьте освободить контроллер
    super.dispose();
  }
  void _updateNewsWithServerResponse(NewsDto newsItem, Map<String, dynamic> response) {
    newsItem.likesNotifier.value = response['likes'] ?? newsItem.likesNotifier.value;
    newsItem.dislikesNotifier.value = response['dislikes'] ?? newsItem.dislikesNotifier.value;
    // Нет необходимости в вызове setState, так как ValueListenableBuilder автоматически обновит UI
  }


  void _likeNews(int newsId, int idUser) async {
    try {
      final response = await _newsService.likeNews(newsId, idUser);
      if (!response.containsKey('error')) {
        final index = newsData.indexWhere((news) => news.newsId == newsId);
        if (index >= 0) {
          _updateNewsWithServerResponse(newsData[index], response);
        }
      } else {
        print(response['error']);
      }
    } catch (e) {
      print('Error liking news: $e');
    }
  }


  void _dislikeNews(int newsId, int idUser) async {
    try {
      final response = await _newsService.dislikeNews(newsId, idUser);
      if (!response.containsKey('error')) {
        final index = newsData.indexWhere((news) => news.newsId == newsId);
        if (index >= 0) {
          _updateNewsWithServerResponse(newsData[index], response);
        }
      } else {
        print(response['error']);
      }
    } catch (e) {
      print('Error disliking news: $e');
    }
  }






  Future<Image> _fetchPicture(String? pictureId) async {
    if (_imageCache.containsKey(pictureId)) {
      return _imageCache[pictureId]!;
    }

    try {
      final Dio _dio = Dio();
      _dio.options.responseType = ResponseType.bytes;
      Response<List<int>> response = await _dio.get('$api/Pictures/$pictureId');
      if (response.statusCode == 200) {
        final photoData = response.data;
        final image = Image.memory(Uint8List.fromList(photoData!));
        _imageCache[pictureId!] = image; // Кэшируем изображение
        return image;
      } else {
        print('Failed to fetch picture data with status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching picture data: $error');
    }

    return Image.asset('assets/images/placeholder_image.jpg');
  }

  Future<List<int>> _fetchUserPhotos(int userID) async {
    if (_userPhotoCache.containsKey(userID)) {
      return _userPhotoCache[userID]!;
    }

    try {
      final Dio _dio = Dio();
      _dio.options.responseType = ResponseType.bytes;
      Response<List<int>> response =
      await _dio.get('$api/Users/user-photos/$userID');

      if (response.statusCode == 200) {
        final userPhotos = response.data;
        _userPhotoCache[userID] = userPhotos!; // Кэшируем данные о пользователе
        return userPhotos;
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
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child:  CustomScrollView(
        key: PageStorageKey('news_screen_scroll_view'), // Добавляем ключ
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            title: Text('Новости'),
            backgroundColor: Colors.deepOrangeAccent,
            floating: true,
            automaticallyImplyLeading: false,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                if (index >= newsData.length) {
                  return isLoading ? Center(child: CircularProgressIndicator()) : null;
                }
                NewsDto newsItem = newsData[index];
                return Column(
                  children: [
                    Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[700]?.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        clipBehavior: Clip.antiAlias, // Добавляем это для скругления изображения
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<Image>(
                              future: _fetchPicture(newsItem.pictureId.toString()),
                              builder: (context, snapshot) {
                                Widget content;
                                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                  content = snapshot.data!;
                                } else {
                                  content = Center(child: CircularProgressIndicator());
                                }
                                return AspectRatio(
                                  aspectRatio: 1 / 1, // Соотношение сторон 1 к 1 для квадрата
                                  child: Container(
                                    width: double.infinity, // Занимает всю возможную ширину
                                    child: content,
                                  ),
                                );
                              },
                            ),

                            Padding( // Добавляем отступы внутри контейнера для текста и кнопок
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FutureBuilder<List<int>>(
                                    future: _fetchUserPhotos(newsItem.idUser),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                        return Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundImage: MemoryImage(Uint8List.fromList(snapshot.data!)),
                                              radius: 20,
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _formatDateTime(newsItem.sendingTime),
                                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                                  ),
                                                  Text(
                                                    newsItem.description,
                                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      } else {
                                        return CircleAvatar(radius: 20, backgroundColor: Colors.grey);
                                      }
                                    },
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.thumb_up),
                                        onPressed: () => _likeNews(newsItem.newsId, int.parse(IDUser)),
                                      ),
                                      ValueListenableBuilder(
                                        valueListenable: newsItem.likesNotifier,
                                        builder: (context, value, child) {
                                          return Text('$value ');
                                        },
                                      ),                                      IconButton(
                                        icon: Icon(Icons.thumb_down),
                                        onPressed: () => _dislikeNews(newsItem.newsId, int.parse(IDUser)),
                                      ),
                                      ValueListenableBuilder(
                                        valueListenable: newsItem.dislikesNotifier,
                                        builder: (context, value, child) {
                                          return Text('$value ');
                                        },
                                      ),
                                      const IconButton(
                                          onPressed: null,
                                          icon: Icon(Icons.messenger_outlined))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ],
                );
              },
              childCount: newsData.length + (isLoading ? 1 : 0),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(bottom: 80), // Дополнительный отступ внизу списка
          ),
        ],
      ),
      )
    );
  }

  Future<void> _onRefresh() async {
    setState(() {
      currentPage = 1; // Сбросить текущую страницу, если необходимо
      newsData.clear(); // Очистить существующие данные
      isLoading = false; // Установить флаг загрузки в false
    });
    await _fetchNewsData(); // Загрузить данные снова
  }


  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
