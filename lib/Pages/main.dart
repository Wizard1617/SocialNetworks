/*
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_network/Models/User.dart';
import 'package:flutter/cupertino.dart';
 // Путь к файлу с классом User
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import 'Auth.dart';
import 'Navigation.dart';


String login="";
String password="";
*/
/*final dio = Dio();
final http = HttpClientAdapter();
String api = 'http://192.168.12.212:5108/api';
var IDUser = '';*//*



*/
/*
Future<dynamic> getID() async{
  Response response;
  response = await dio.get('$api/Users/GetUserIdByLogin?loginUser=$login');
  print(response.data.toString());
  IDUser = response.data.toString();

}



Future<dynamic> request() async {
  login = _loginController.text;
  password = _passwordController.text;
  Response response;
  response = await dio.get('$api/Users/$login/$password');
  print(response.data.toString());

}

void registration() async{
  String firstName = _firstNameController.text;
  String lastName = _lastNameController.text;
  String login = _loginController.text;
  String password = _passwordController.text;
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
*//*


var loginUsers='';
var lastNames ='';
late User user;


// Вызываете функцию для выполнения GET-запроса и обработки данных.

void data_recording(){
  print(loginUsers+' '+lastNames);
}

// сохранение сесси пользователя
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Обязательно инициализируйте WidgetsFlutterBinding

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
        useMaterial3: true,
      ),
      home: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

*/
/*Future<void> _getUserInfoFromPrefs() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final int userId = prefs.getInt('userId') ?? 0;
  final String firstName = prefs.getString('firstName') ?? '';
  final String lastName = prefs.getString('lastName') ?? '';
  final String loginUser = prefs.getString('loginUser') ?? '';

  // Полученные данные теперь могут быть использованы в вашем приложении
  print('Is Logged In: $isLoggedIn');
  print('User ID: $userId');
  print('First Name: $firstName');
  print('Last Name: $lastName');
  print('Login User: $loginUser');
  // Добавьте обработку остальных полей пользователя по аналогии
}*//*





class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      final darkTheme = ThemeData.dark().copyWith(
        textTheme: ThemeData.dark().textTheme.copyWith(
          bodyMedium: const TextStyle(color: Colors.white, fontFamily: 'Roboto Italic'),
        ),
      );
      return FutureBuilder<User>(
        future: getUserInfoFromSharedPreferences(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              user = snapshot.data!;
              return NavigationScreen(user: user);
            } else {
              return const CircularProgressIndicator();
            }
          } else {
            return const CircularProgressIndicator();
          }
        },
      );
    } else {
      return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
          useMaterial3: true,

        ),
        home: const Authorization(),
      );
    }
  }
}

*/
/*
class UploadPhotoScreen extends StatefulWidget {
  @override
  _UploadPhotoScreenState createState() => _UploadPhotoScreenState();
}

class _UploadPhotoScreenState extends State<UploadPhotoScreen> {
  final Dio _dio = Dio();

  File? _selectedImage;

  Future<void> uploadUserPhoto(int userId, File imageFile) async {
    try {
      // Открываем файл в бинарном режиме для передачи в запросе
      final List<int> bytes = imageFile.readAsBytesSync();

      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: 'user_photo.jpg'),
      });

      Response response = await dio.post(
        '$api/Users/upload-photo/$userId',
        data: formData,
      );
      print('Аййййййййййййййййййййййййййййййди $userId');
      print(response);
      print(formData);
      if (response.statusCode == 200) {
        print('Фото успешно загружено. ID фото: ${response.data['photoID']}');
      } else {
        print('Ошибка при загрузке фото: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при загрузке фото: $e');
    }
  }


  Future<void> _selectImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final File tempFile = File(pickedImage.path);
      setState(() {
        _selectedImage = tempFile;
      });

      // Загрузите фото на сервер
      await uploadUserPhoto(int.parse(IDUser), _selectedImage!);
    }
  }





  Future<void> _uploadImage(int userId, File file) async {
    if (file == null || !(await file.exists())) {
      print('Selected image does not exist.');
      return;
    }

    FormData formData = FormData.fromMap({
      'userId': IDUser, // Передайте userId в URL-адресе
      'file': await MultipartFile.fromFile(
        _selectedImage!.path,
        filename: 'photo.jpg',
      ),
    });


    try {
      Response response = await _dio.post('$api/Users/upload-photo/$IDUser', data: formData);
      print(response);
      print(_selectedImage);
      print('Ааааааааааааааааааааййййди $IDUser');

      if (response.statusCode == 200) {
        // Здесь вы можете обработать успешный ответ, например, получить PhotoID.
        print('Image uploaded successfully: ${response.data}');
      } else {
        print('Upload failed with status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Photo'),
      ),
      body: Column(
        children: [
          if (_selectedImage != null)
            Image.file(_selectedImage!, height: 200, width: 200,)
          else
            Text('No Image Selected'),
          ElevatedButton(
            onPressed: _selectImage,
            child: Text('Select Image'),
          ),
          ElevatedButton(
            onPressed: () => _uploadImage(int.parse(IDUser), _selectedImage!),
            child: Text('Upload Image'),
          ),


        ],
      ),
    );
  }
}




class UserPhotosScreen extends StatefulWidget {
  final int userId;

  UserPhotosScreen({required this.userId});

  User? user;
  UserPhotosScreen.withUser({required this.userId, required this.user});

  @override
  _UserPhotosScreenState createState() => _UserPhotosScreenState(userId);

}

class _UserPhotosScreenState extends State<UserPhotosScreen> {
  final Dio _dio = Dio();
  final int userId;

  _UserPhotosScreenState(this.userId) {
    _dio.options.responseType = ResponseType.bytes;
  }
  List<Image> photoImages = [];

  Future<void> _fetchUserPhotos() async {
    try {
      Response<List<int>> response = await _dio.get('$api/Users/user-photos/$IDUser');
      if (response.statusCode == 200) {
        final photoData = response.data;
        setState(() {
          final image = Image.memory(Uint8List.fromList(photoData!));
          photoImages.add(image);
        });
      } else {
        // Обработка ошибки
        print('Failed to fetch user photos with status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  @override
  void initState() {
    super.initState();
    getUserInfoFromSharedPreferences().then((userInfo) {
      setState(() {
        widget.user = userInfo;
      });
      _fetchUserPhotos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Photos'),
      ),
      body: ListView.builder(
        itemCount: photoImages.length,
        itemBuilder: (context, index) {
          return photoImages[index];
        },
      ),
    );
  }
}*//*


*/
