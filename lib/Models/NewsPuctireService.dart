import 'package:dio/dio.dart';

import '../Api/ApiRequest.dart';

class NewsPuctireService {
  Dio _dio = Dio();

  Future<Map<String, dynamic>> postNewsPuctire({

    required int pictureId,
    required int newsId,
  }) async {
    try {
      Response response = await _dio.post(
        '$api/NewsPuctires',
        data: {
          'pictureId': pictureId,
          'newsId': newsId,
        },
      );

      return response.data;
    } catch (e) {
      print('Error posting newsPuctire: $e');
      throw e;
    }
  }
}
