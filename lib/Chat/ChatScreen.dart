import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_network/Chat/FullscreenVideoPlayer.dart';
import 'package:social_network/Chat/VideoWidget.dart';
import 'package:social_network/Models/MessageFile.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Api/ApiRequest.dart';
import 'PDFViewerWidget.dart';
import '../Models/Correspondence.dart';
import '../Models/MessageUser.dart';
import '../Service/MyFirebaseMessagingService.dart';
import '../main.dart';
import '../Pages/UserProfile.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

String newMessage = 'r';
class ChatScreen extends StatefulWidget {
  final int senderId;
  final int recipientId;
  final Uint8List? senderAvatar;
  final Uint8List? recipientAvatar;
  final String nameUser;

  ChatScreen({
    required this.senderId,
    required this.recipientId,
    this.senderAvatar,
    this.recipientAvatar,
    required this.nameUser,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>   {
  List<File> selectedFiles = [];

  TextEditingController messageController = TextEditingController();
  List<Map<String, dynamic>> messages = []; // Используйте Map для хранения информации о сообщениях
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  ScrollController _scrollController = ScrollController();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  MyFirebaseMessagingService _firebaseMessagingService = MyFirebaseMessagingService();


  Future<void> checkPermissions(BuildContext context) async {
    var storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      // Запрос разрешения
      var result = await Permission.storage.request();
      if (result.isGranted) {
        // Разрешение предоставлено, можно продолжать загрузку файла
      } else {
        // Показываем уведомление, что разрешение не предоставлено
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Необходимо разрешение на доступ к хранилищу"),
        ));
      }
    } else {
      // Разрешение уже предоставлено, можно продолжать загрузку файла
    }
  }


  Widget _buildFileWidget(String url, String extension, BuildContext context) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      // Используйте Image.network для отображения изображений
        return Image.network(url);
      case 'mp4':
      case 'avi':
      // Используйте виджет видеоплеера для отображения видео
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => FullscreenVideoPlayer(url: url),
          ));
        },
        child: VideoWidget(url: url),
      );// Это ваш пользовательский виджет для видео
   /*   case 'pdf':
      // Используйте PDFViewer для отображения PDF
        return PDFViewerWidget(url: url);*/ // Это ваш пользовательский виджет для PDF
      case 'doc':
      case 'docx':
      case 'xls':
      case 'xlsx':
      // Кнопка для скачивания и открытия документа
        return ListTile(
          leading: Icon(Icons.file_copy),
          title: Text("Скачать и открыть документ"),
          onTap: () async {
            // Запросите разрешение на доступ к хранилищу, если оно еще не предоставлено
            var status = await Permission.storage.request();
            if (status.isGranted) {
              final externalDir = await getExternalStorageDirectory();
              final taskId = await FlutterDownloader.enqueue(
                url: url,
                savedDir: externalDir!.path,
                showNotification: true,
                // Название файла
                fileName: 'Документ',
                openFileFromNotification: true,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Необходимо разрешение на доступ к хранилищу"),
              ));
            }
          },
        );
      default:
      // Если формат файла не поддерживается, отобразите иконку файла
        return Icon(Icons.file_present);
    }
  }

// Функция для загрузки файла
  Future<void> downloadAndOpenFile(BuildContext context, String url, String fileName) async {
    // Запрос разрешения на доступ к хранилищу
    var status = await Permission.storage.request();
    if (status.isGranted) {
      // Получение директории для сохранения файла
      final externalDir = await getExternalStorageDirectory();
      final savePath = path.join(externalDir!.path, fileName); // Исправлено здесь

      // Запуск загрузки файла
      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: externalDir.path,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );

      // Подписка на прослушивание состояния загрузки
      FlutterDownloader.registerCallback((id, status, progress) {
        if (taskId == id && status == DownloadTaskStatus.complete) {
          // Открытие файла после завершения загрузки
          OpenFile.open(savePath);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Загрузка файла начата"),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Необходимо разрешение на доступ к хранилищу"),
      ));
    }
  }


  List<Image> photoImages = [];
  late File _selectedFile;
  bool _fileIsSelected = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx', 'xls', 'xlsx', 'mp4', 'avi'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      setState(() {
        _selectedFile = File(file.path!);
        _fileIsSelected = true;
      });
    } else {
      // Пользователь отменил выбор файла
    }
  }






  @override
  void initState() {
    super.initState();
    _firebaseMessagingService.initializeNotifications();

    if (!kIsWeb) {
      _checkAndSubscribeToTopic();
      _firebaseMessaging.getToken().then((token) {
        print('FCM Token: $token');
        saveTokenToServer(token!);
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("onMessage: $message");

        print("From: ${message.from}");
        print("Notification Data: ${message.data}");

        showNotification(
            'Новое сообщениеуу' ?? 'Default itle',
            message.notification?.body ?? 'Default ody   $newMessage', newMessage
        );

      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("onMessageOpenedApp: $message");
      });
    }
    _fetchUserPhotos();
    _fetchMessages(); // Call _fetchMessages here
  }


  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    else{    print("Разрешение на хранилище отклонено");
    }
  }



// Функция для проверки и подписки на тему
  Future<void> _checkAndSubscribeToTopic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isSubscribed = prefs.getBool('isSubscribed_${widget.recipientId}') ?? false;

    if (!isSubscribed) {
      _firebaseMessaging.subscribeToTopic('chat_${widget.recipientId}');
      prefs.setBool('isSubscribed_${widget.recipientId}', true);
    }
  }

  Future<void> saveTokenToServer(String token) async {
    try {
      // Ваш код для отправки токена на сервер
      // Замените 'your_api_endpoint' на реальный URL вашего API
      await dio.post('$api/FcmTokens/save-token', data: {'userId': IDUser,'token': token});
      print('Токен успешно сохранен на сервере');
    } catch (error) {
      // Обработка ошибок при сохранении токена на сервере
      print('Ошибка при сохранении токена на сервере: $error');
      // Возможно, вы хотите также показать пользователю сообщение об ошибке
    }
  }


  Future<void> initializeNotifications() async {
    var androidSettings = const AndroidInitializationSettings('ic_launcher');
    var initSettings = InitializationSettings(android: androidSettings);

    // Инициализация плагина
    await flutterLocalNotificationsPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          onSelectNotification(response.payload);
        });
    print("Notifications are initialized.");

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print("Initial message: ${message.data}");
        onSelectNotification(message.toString());
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp: ${message.data}");
      onSelectNotification(message.toString());
    });
  }
  Future<void> onSelectNotification(String? payload) async {
    print("onSelectNotification called with payload: $payload");

    if (payload != null) {
      // Пример десериализации JSON строки в объект
      final data = jsonDecode(payload);
      final String recipientId = data['recipientId'];
      final String senderId = data['senderId'];
      final String nameUser = data['nameUser'];

      // Теперь используйте эти значения для навигации
      if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => ChatScreen(
          recipientId: int.parse(recipientId),
          senderId: int.parse(senderId),
          nameUser: nameUser,
          senderAvatar: null,
          recipientAvatar: null,
        )));
      }
    }
  }


  Future<void> showNotification(String title, String body, String messageText) async {
    // Проверка, следует ли показывать уведомление в мобильном приложении
    bool shouldShowMobileNotification = false;
    if (shouldShowMobileNotification) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        '1622228238850543549',
        'Новое сообщение',
        importance: Importance.max,
        priority: Priority.high,
        icon: 'iconpush',
      );

      const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

      try {
        await flutterLocalNotificationsPlugin.show(
          0,
          title ?? 'Default Titl',
          body ?? 'Default Bod',
          platformChannelSpecifics,
          payload: messageText,
        );
      } catch (e) {
        print('Ошибка при показе уведомления: $e');
      }
    }
  }
  Future<void> _fetchMessages() async {
    try {
      final response = await _getMessagesFromApi();
      if (response.statusCode == 200) {
        final List<dynamic> messageData = response.data;
        final List<Map<String, dynamic>> loadedMessages = [];
        for (final messageJson in messageData) {
          final message = MessageUser.fromJson(messageJson);
          // Теперь добавляем файлы в loadedMessages
          loadedMessages.add({
            'message': message.textMessage,
            'sender': message.senderId == widget.senderId ? 'self' : 'other',
            'time': message.sendingTime.toLocal().toString(),
            'messageFiles': message.messageFiles.map((file) => file.file_Url).toList(), // Добавление URL файлов
          });
        }
        setState(() {
          messages = loadedMessages;
        });
      } else {
        print('Не удалось получить сообщения. Статус код: ${response.statusCode}');
      }
    } catch (error) {
      print('Ошибка при получении сообщений: $error');
    }
  }

  Future<Response<dynamic>> _getMessagesFromApi() async {
    try {
      return await dio.get(
        '$api/Correspondences/GetMessagesByUsers?userId=${widget.senderId}&senderId=${widget.recipientId}',
      );
    } catch (e) {
      throw 'Ошибка при выполнении запроса к API: $e';
    }
  }




  Future<void> _fetchUserPhotos() async {
    try {
      final Dio _dio = Dio();

      _dio.options.responseType = ResponseType.bytes;
      Response<List<int>> response = await _dio.get(
          '$api/Users/user-photos/$IDUser');
      if (response.statusCode == 200) {
        final photoData = response.data;
        setState(() {
          final image = Image.memory(Uint8List.fromList(photoData!));
          photoImages.add(image);
        });
      } else {
        // Обработка ошибки
        print('Failed to fetch user photos with status code: ${response
            .statusCode}');
      }
      scrollToBottom();
    } catch (error) {
      print('Errorssssssssssss: $error');
    }
  }

  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: widget.recipientAvatar != null
                  ? MemoryImage(widget.recipientAvatar!)
                  : null,
            ),
            SizedBox(width: 10),
            Text(
              widget.nameUser,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,

              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                bool isSender = message['sender'] != 'self';
                List<String> fileUrls = message['messageFiles']; // Используем список URL файлов здесь

                return Column(
                  children: [
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        if (!isSender) SizedBox(width: 10),
                        Flexible(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            child: Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25.0),
                                color: isSender ? Colors.deepOrangeAccent : Colors.grey[300],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: message['message'],
                                          style: TextStyle(fontSize: 16, color: isSender ? Colors.white : Colors.black),
                                        ),
                                        TextSpan(text: " "),
                                        TextSpan(
                                          text: message['time'].length >= 16
                                              ? message['time'].substring(11, 16)
                                              : message['time'],
                                          style: TextStyle(fontSize: 12, color: isSender ? Colors.white70 : Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ...fileUrls.map((url) {
                                    String extension = url.split('.').last; // Получаем расширение файла из URL
                                    return Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: _buildFileWidget(url, extension, context), // Используем нашу функцию для выбора виджета
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (isSender) SizedBox(width: 10),
                      ],
                    ),
                    SizedBox(height: 8),
                  ],
                );
              },
            ),
          ),


          if (_fileIsSelected) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _selectedFile.path.endsWith('.jpg') || _selectedFile.path.endsWith('.png')
                  ? Image.file(_selectedFile, width: 100, height: 100)
                  : Text(basename(_selectedFile.path)),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Введите сообщение...',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.attach_file),
                        onPressed: () async {
                          await _pickFile();
                        },
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Future<int> postMessageUser(String textMessage, DateTime sendingTime) async {
    try {
      final response = await dio.post(
        '$api/MessageUsers',
        data: {
          'textMessage': textMessage,
          'sendingTime': sendingTime.toIso8601String(),
          'userId': IDUser,
          'senderId': widget.recipientId,
        },
      );

      if (response.statusCode == 201) {
        print('MessageUser posted successfully');
        final messageId = response.data['idMessage'];
        return messageId;
      } else {
        print('Failed to post MessageUser with status code: ${response.statusCode}');
        throw 'Failed to post MessageUser with status code: ${response.statusCode}';
      }
    } catch (error) {
      print('Error posting MessageUser: $error');
      throw 'Error posting MessageUser: $error';
    }
  }


  Future<void> sendMessage() async {
    String textMessage = messageController.text.trim();

    if (textMessage.isEmpty && !_fileIsSelected) {
      print('Нет текста или файла для отправки');
      return;
    }

    if (!textMessage.isEmpty) {
      // Отправка текстового сообщения и получение idMessage
      int messageId = await postMessageUser(textMessage, DateTime.now());

      if (_fileIsSelected) {
        // Отправка файла на сервер
        await _uploadFile(_selectedFile, messageId);
      }

      setState(() {
        messageController.clear();
        _fileIsSelected = false;
      });
    }
  }

  Future<void> _uploadFile(File file, int messageId) async {
    String fileName = basename(file.path);
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
      "messageId": messageId,
    });

    Dio dio = Dio();
    try {
      Response response = await dio.post(
        "$api/Files/upload", // Укажите URL вашего API
        data: formData,
      );

      if (response.statusCode == 200) {
        print("Файл успешно загружен");
      } else {
        print("Ошибка при загрузке файла");
      }
    } catch (e) {
      print("Ошибка при отправке файла: $e");
    }
  }

}


Future<void> onSelectNotification(String? payload) async {
  if (payload != null) {
    final data = jsonDecode(payload);
    final recipientId = data['recipientId'] as String?;
    final senderId = data['senderId'] as String?;
    final nameUser = data['nameUser'] as String?;

    if (recipientId != null && senderId != null && nameUser != null) {
      if (navigatorKey.currentState != null) {
        // Пример навигации к экрану чата. Убедитесь, что у вас есть правильные идентификаторы и данные.
        navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => ChatScreen(
          recipientId: int.parse(recipientId),
          senderId: int.parse(senderId),
          nameUser: nameUser,
          senderAvatar: null, // Здесь добавьте логику для аватаров, если нужно
          recipientAvatar: null,
        )));
      }
    }
  }
}
