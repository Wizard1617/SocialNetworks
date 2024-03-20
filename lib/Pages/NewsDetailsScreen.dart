import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:social_network/Models/NewsDto.dart';
import '../Api/ApiRequest.dart';
import '../Models/NewsService.dart';
import 'EditNews.dart'; // Убедитесь, что у вас есть эта страница для редактирования новостей
import 'Profile.dart'; // Подключите вашу страницу профиля, если она используется

class NewsListScreen extends StatefulWidget {
  final List<NewsDto> newsList;

  const NewsListScreen({Key? key, required this.newsList}) : super(key: key);

  @override
  _NewsListScreenState createState() => _NewsListScreenState();
}


class _NewsListScreenState extends State<NewsListScreen> with AutomaticKeepAliveClientMixin {

  bool _isLoading = true;
  @override
  bool get wantKeepAlive => true;

  final NewsService _newsService = NewsService();

  void _likeNews(NewsDto newsItem, int idUser) async {
    try {
      final response = await _newsService.likeNews(newsItem.newsId, idUser);
      if (!response.containsKey('error')) {
        // Обновляем данные новости с ответом сервера
        newsItem.likesNotifier.value = response['likes'];
        newsItem.dislikesNotifier.value = response['dislikes'] ?? newsItem.dislikesNotifier.value;
        newsItem.likedByCurrentUser = response['likedByCurrentUser'];
        newsItem.dislikedByCurrentUser = response['dislikedByCurrentUser'] ?? false;
      } else {
        print(response['error']);
      }
    } catch (e) {
      print('Error liking news: $e');
    }
  }

  void _dislikeNews(NewsDto newsItem, int idUser) async {
    try {
      final response = await _newsService.dislikeNews(newsItem.newsId, idUser);
      if (!response.containsKey('error')) {
        // Обновляем данные новости с ответом сервера
        newsItem.dislikesNotifier.value = response['dislikes'];
        newsItem.likesNotifier.value = response['likes'] ?? newsItem.likesNotifier.value;
        newsItem.dislikedByCurrentUser = response['dislikedByCurrentUser'];
        newsItem.likedByCurrentUser = response['likedByCurrentUser'] ?? false;
      } else {
        print(response['error']);
      }
    } catch (e) {
      print('Error disliking news: $e');
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
        print('Failed to fetch picture data with status code: ${response
            .statusCode}');
      }
    } catch (error) {
      print('Error fetching picture data: $error');
    }
    return Image.asset('assets/images/placeholder_image.jpg');
  }

  void _editNews(BuildContext context, NewsDto newsItem) async {
    final updatedDescription = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNews(
          newsId: newsItem.newsId,
          initialDescription: newsItem.description,
        ),
      ),
    );

    // Проверяем, вернулось ли обновленное описание
    if (updatedDescription != null && updatedDescription is String) {
      setState(() {
        // Обновляем описание новости в списке
        newsItem.description = updatedDescription;
      });
    }
  }


  void _deleteNews(BuildContext context, NewsDto newsItem) async {
    try {
      await NewsService().deleteNews(newsItem.newsId);
      setState(() {
        widget.newsList.removeWhere((news) => news.newsId == newsItem.newsId);
      });
    } catch (e) {
      print('Error deleting news: $e');
    }
  }
  final PageStorageKey _key = PageStorageKey('news-list');

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          key: _key, // Уникальный ключ для сохранения состояния прокрутки
          slivers: <Widget>[
            SliverAppBar(
              title: Text('Новости'),
              backgroundColor: Colors.deepOrangeAccent,
              floating: true,
              automaticallyImplyLeading: true,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  // Проверка на последний элемент для отображения индикатора загрузки
                  if (index >= widget.newsList.length) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final NewsDto newsItem = widget.newsList[index];

                  return Column(
                    children: [
                      Center(
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
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
                                    aspectRatio: 1 / 1,
                                    child: Container(
                                      width: double.infinity,
                                      child: content,
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(height: 8),
                                Text(
                                    newsItem.description,
                                    style: TextStyle(fontSize: 16)
                                ),
                                Text(
                                    _formatDateTime(newsItem.sendingTime),
                                    style: TextStyle(fontSize: 16)
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(newsItem.likedByCurrentUser
                                              ? Icons.thumb_up
                                              : Icons.thumb_up_alt_outlined),
                                          onPressed: () => _likeNews(newsItem, int.parse(IDUser)),
                                        ),
                                        ValueListenableBuilder<int>(
                                          valueListenable: newsItem.likesNotifier,
                                          builder: (context, likes, _) => Text('$likes'),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                              newsItem.dislikedByCurrentUser ? Icons
                                                  .thumb_down : Icons
                                                  .thumb_down_alt_outlined),
                                          onPressed: () => _dislikeNews(newsItem, int.parse(IDUser)) ,
                                        ),
                                        ValueListenableBuilder<int>(
                                          valueListenable: newsItem.dislikesNotifier,
                                          builder: (context, dislikes, _) => Text('$dislikes'),
                                        ),
                                      ],
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _editNews(context, newsItem);
                                        } else if (value == 'delete') {
                                          _deleteNews(context, newsItem);
                                        }
                                      },
                                      itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry<String>>[
                                        const PopupMenuItem<String>(
                                          value: 'edit',
                                          child: Text('Редактировать'),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Text('Удалить'),
                                        ),
                                      ],
                                    ),
                                  ],

                                ),
                              ]),
                              )],
                          ),
                        ),
                      ),
                    ],
                  );
                },
                childCount: widget.newsList.length, // Укажите здесь общее количество элементов в списке
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    // Ваш код для обновления списка новостей
  }
}
String _formatDateTime(DateTime dateTime) {
  return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}
