import 'package:dio/dio.dart';

import '../Api/ApiRequest.dart';

class PictureService {
  Dio _dio = Dio();

  Future<Map<String, dynamic>> postPicture({
    required String photoData,
    required String uploadDate,
  }) async {
    try {
      Response response = await _dio.post(
        '$api/Pictures',
        data: {
          'photoData': photoData,
          'uploadDate': uploadDate,
        },
      );

      return response.data;
    } catch (e) {
      print('Error posting picture: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getPictures() async {
    try {
      final response = await _dio.get('$api/Pictures');
      if (response.statusCode == 200) {
        return (response.data as List).cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load pictures data');
      }
    } catch (e) {
      throw Exception('Failed to load pictures data');
    }
  }
}