import 'dart:convert';

import 'package:dio/dio.dart';

final dio = Dio();
final http = HttpClientAdapter();
String api = 'http://192.168.12.212:5108/api';
var IDUser = '';


Future<dynamic> getID(String login) async{
  Response response;
  response = await dio.get('$api/Users/GetUserIdByLogin?loginUser=$login');
  print(response.data.toString());
  IDUser = response.data.toString();

}

/*String login="";
String password="";*/

Future<dynamic> request(String login, String password) async {
/*  login = _loginController.text;
  password = _passwordController.text;*/
  Response response;
  try {
    Response response = await dio.get('$api/Users/$login/$password');
    print(response.data.toString());
    // Handle the response here
  } catch (e) {
    if (e is DioError) {
      print("Dio Error: ${e.message}");
      print("Dio Response: ${e.response?.data}");
    }
  }
}

void registration(String firstName, String lastName, String login, String password) async{
  /*String firstName = _firstNameController.text;
  String lastName = _lastNameController.text;
  String login = _loginController.text;
  String password = _passwordController.text;*/
  Response response;
  response = await dio.post('$api/Users', data: {
    'firstName': firstName,
    'lastName': lastName,
    'loginUser': login,
    'passwordUser': password,
    'numberOfMessages': 0,
    'roleId': 1,
    'role': {
      "idRole": 0,
      "nameRole": "string"
    }
  });
}



Future<bool> isFriendRequestSent(int recipientId, int senderId) async {
  final url = '$api/Applications'; // Замените на ваш URL

  try {
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> applications = List.from(response.data);
      final isRequestSent = applications.any((app) =>
      app['recipientId'] == recipientId && app['senderId'] == senderId);

      return isRequestSent;
    } else {
      print('Failed to fetch applications with status code: ${response.statusCode}');
      return false;
    }
  } catch (error) {
    print('Error fetching applications: $error');

    return false;
  }
}

Future<void> sendFriendRequest(int recipientId, int senderId) async {
  final url = '$api/Applications'; // Замените на ваш URL

  try {
    final response = await dio.post(
      url,
      data: {
        'recipientId': recipientId,
        'senderId': senderId,
      },
    );
    print('Error sending friend request: ${response.statusCode}');
    print('Server response: ${response.data}');

    if (response.statusCode == 201) {
      print('Friend request sent successfully');
    } else {
      print('Failed to send friend request with status code: ${response.statusCode}');
    }
  } catch (error) {
    print('Error sending friend request: $error');

  }
}


Future<Response> postFriendRequest(int userId, int friendsId) async {
  try {
    final response = await Dio().post(
      '$api/Friends',
      data: {
        'userId': userId,
        'friendsId': friendsId,
      },
    );
    return response;
  } catch (error) {
    throw error;
  }
}

Future<Response> deleteApplication(int applicationId) async {
  try {
    final response = await Dio().delete('$api/Applications/$applicationId');
    return response;
  } catch (error) {
    throw error;
  }
}

Future<int?> getApplicationIdByUserIds(int recipientId, int senderId) async {
  try {
    final response = await Dio().get('$api/Applications');
    if (response.statusCode == 200) {
      final List<dynamic> applications = response.data;
      final application = applications.firstWhere(
            (app) => app['recipientId'] == recipientId && app['senderId'] == senderId,
        orElse: () => null,
      );

      if (application != null) {
        return application['idApplications'];
      }
    }
  } catch (error) {
    throw error;
  }
  return null;
}

Future<bool> isUserInFriends(int userId, int friendsId) async {
  try {
    final response = await Dio().get('$api/Friends');
    if (response.statusCode == 200) {
      final List<dynamic> friends = response.data;
      return friends.any((friend) => friend['userId'] == userId && friend['friendsId'] == friendsId);
    }
  } catch (error) {
    throw error;
  }
  return false;
}

Future<List<NewsPuctireData>> getNewsPuctires() async {
  try {
    final response = await dio.get('$api/NewsPuctires');
    if (response.statusCode == 200) {
      final List<Map<String, dynamic>> newsPuctires = (response.data as List).cast<Map<String, dynamic>>();
      List<NewsPuctireData> result = [];

      for (var newsPuctire in newsPuctires) {
        final pictureId = newsPuctire['pictureId'];
        final newsId = newsPuctire['newsId'];

        final pictureResponse = await dio.get('$api/Pictures/$pictureId');
        final newsResponse = await dio.get('$api/News/$newsId');

        if (pictureResponse.statusCode == 200 && newsResponse.statusCode == 200) {
          final pictureData = pictureResponse.data;
          final newsData = newsResponse.data;

          result.add(NewsPuctireData(
            pictureData: pictureData,
            newsData: newsData,
          ));
        }
      }

      return result;
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    throw Exception('Failed to load data');
  }
}

class NewsPuctireData {
  final Map<String, dynamic> pictureData;
  final Map<String, dynamic> newsData;

  NewsPuctireData({required this.pictureData, required this.newsData});
}
