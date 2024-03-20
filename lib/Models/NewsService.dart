import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:social_network/Models/NewsDto.dart';

import '../Api/ApiRequest.dart';

class NewsService {
  Dio _dio = Dio();

  Future<Map<String, dynamic>> postNews({
    required String description,
    required int likes,
    required int disLike,
    required int idUser,
    required int pictureId,
    required DateTime sendingTime,
  }) async {
    try {
      // Format the DateTime as a string before sending the request
      String formattedSendingTime =
          "${sendingTime.year}-${sendingTime.month.toString().padLeft(2, '0')}-${sendingTime.day.toString().padLeft(2, '0')}T${sendingTime.hour.toString().padLeft(2, '0')}:${sendingTime.minute.toString().padLeft(2, '0')}:${sendingTime.second.toString().padLeft(2, '0')}";

      Response response = await _dio.post(
        '$api/News',
        data: {
          'description': description,
          'likes': likes,
          'disLike': disLike,
          'sendingTime': formattedSendingTime,
          'idUser': idUser,
          'pictureId': pictureId,
        },
      );

      return response.data;
    } catch (e) {
      print('Error posting news: $e');
      throw e;
    }
  }

  Future<void> editNews({
    required int newsId,
    required String newDescription,
  }) async {
    try {
      await _dio.put(
        '$api/News/$newsId',
        queryParameters: {'newDescription': newDescription},
      );
    } catch (e) {
      print('Error editing news: $e');
      throw e;
    }
  }
  Future<Map<String, dynamic>> likeNews(int newsId, int idUser) async {
    try {
      final response = await _dio.put(
        '$api/News/like/$newsId',
        queryParameters: {'idUser': idUser},
      );
      if (response.statusCode == 200) {
        // Предполагаем, что сервер возвращает JSON с нужными полями
        return response.data; // response.data должен быть типа Map<String, dynamic>
      } else {
        print('Failed to like news. Status code: ${response.statusCode}');
        return {'error': 'Failed to like news'}; // Возвращаем Map с сообщением об ошибке
      }
    } catch (e) {
      print('Error liking news: $e');
      return {'error': 'Error liking news'}; // Возвращаем Map с сообщением об ошибке
    }
  }

  Future<Map<String, dynamic>> dislikeNews(int newsId, int idUser) async {
    try {
      final response = await _dio.put(
        '$api/News/dislike/$newsId',
        queryParameters: {'idUser': idUser},
      );
      if (response.statusCode == 200) {
        // Предполагаем, что сервер возвращает JSON с нужными полями
        return response.data; // response.data должен быть типа Map<String, dynamic>
      } else {
        print('Failed to dislike news. Status code: ${response.statusCode}');
        return {'error': 'Failed to dislike news'}; // Возвращаем Map с сообщением об ошибке
      }
    } catch (e) {
      print('Error disliking news: $e');
      return {'error': 'Error disliking news'}; // Возвращаем Map с сообщением об ошибке
    }
  }




  // Добавьте параметры пагинации в метод getNews
  Future<List<NewsDto>> getNews({int pageNumber = 1, int pageSize = 10}) async {
    try {
      final response = await _dio.get(
        '$api/News',
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => NewsDto.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load news data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching news data: $e');
      throw Exception('Failed to load news data');
    }
  }


  Future<void> deleteNews(int newsId) async {
    try {
      // Удалить связанные записи из таблицы News_puctires
      await _dio.delete('$api/News/pictures/$newsId');

      // Удалить связанные записи из таблицы Likes
      await _dio.delete('$api/News/likes/$newsId');

      // Затем удалить саму новость
      await _dio.delete('$api/News/$newsId');
    } catch (e) {
      print('Error deleting news: $e');
      throw e;
    }
  }
}
