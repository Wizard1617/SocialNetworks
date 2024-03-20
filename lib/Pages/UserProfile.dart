import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_network/Pages/Auth.dart';
import '../Api/ApiRequest.dart';
import '../Models/User.dart';
import '../Chat/ChatScreen.dart';

class UserProfile extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String login;
  final int recipientId;
  final int senderId;
  final Uint8List? userPhoto;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.login,
    this.userPhoto,
    required this.recipientId,
    required this.senderId,
  });

  @override
  _UserProfileState createState() => _UserProfileState();
}
String? MaNameUser;
class _UserProfileState extends State<UserProfile> {
  bool isRequestSent = false;
  bool isRequestReceived = false;
  int? applicationId;
  bool isInFriends = false;
  Future<User> user = getUserInfoFromSharedPreferences();

  set anOtherMenuActive(bool anOtherMenuActive) {}

  @override
  void initState() {
    super.initState();
    checkFriendRequest();
    checkIsInFriends();
    _getUserInfoFromPrefs();
  }

  Future<void> _getUserInfoFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final int userId = prefs.getInt('userId') ?? 0;
    final String firstName = prefs.getString('firstName') ?? '';
    final String lastName = prefs.getString('lastName') ?? '';
    final String loginUser = prefs.getString('loginUser') ?? '';
  MaNameUser = lastName;
    user = User(
      id: userId,
      firstName: firstName,
      lastName: lastName,
      loginUser: loginUser,

    ) as Future<User>;

    setState(() {});
  }

  Future<void> checkIsInFriends() async {
    try {
      final inFriends = await isUserInFriends(int.parse(IDUser), widget.recipientId);
      setState(() {
        isInFriends = inFriends;
      });
    } catch (error) {
      print('Ошибка при проверке друзей: $error');
    }
  }

  Future<void> checkFriendRequest() async {
    final requestSent = await isFriendRequestSent(widget.recipientId, widget.senderId);
    final requestReceived = await isFriendRequestSent(widget.senderId, widget.recipientId);

    setState(() {
      isRequestSent = requestSent;
      isRequestReceived = requestReceived;
       anOtherMenuActive = true;
    });
  }

  Future<void> checkIdApplication() async {
    try {
      applicationId = await getApplicationIdByUserIds(int.parse(IDUser), widget.recipientId);
    } catch (error) {
      print('Ошибка при проверке заявки в друзья: $error');
    }
  }

  Future<void> acceptFriendRequest() async {
    try {
      await postFriendRequest(int.parse(IDUser), widget.recipientId);
      await postFriendRequest(widget.recipientId, int.parse(IDUser));
      await checkIdApplication();
      await deleteApplication(applicationId!);
    } catch (error) {
      print('Ошибка при принятии заявки в друзья: $error');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Профиль'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          CircleAvatar(
            radius: 50,
            backgroundImage: widget.userPhoto != null ? MemoryImage(widget.userPhoto!) : null,
          ),
          SizedBox(height: 16),
          // Используем Stack для размещения текста и иконок
          Stack(
            children: [
              // Центрированный текст
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text('${widget.firstName} ${widget.lastName}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('@${widget.login}', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              ),
              // Иконки, выровненные вправо
              Align(
                alignment: Alignment.centerRight  ,
                child: Padding(
                  padding: EdgeInsets.only(right: 30.0, top: 10), // Уменьшаем отступ с правого края
                  child: FutureBuilder<bool>(
                  future: isUserInFriends(int.parse(IDUser), widget.recipientId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.data ?? false) {
                        return Icon(Icons.check, color: Colors.green);
                      } else if (isRequestSent) {
                        return Icon(Icons.hourglass_top, color: Colors.amber);
                      } else if (isRequestReceived) {
                        return IconButton(
                          icon: Icon(Icons.person_add, color: Colors.deepOrangeAccent),
                          onPressed: () async {
                            await acceptFriendRequest();
                            setState(() {});
                          },
                        );
                      } else {
                        return IconButton(
                          icon: Icon(Icons.person_add, color: Colors.deepOrangeAccent),
                          onPressed: () async {
                            await sendFriendRequest(widget.recipientId, widget.senderId);
                            setState(() {
                              isRequestSent = true;
                            });
                          },
                        );
                      }
                    }
                    return SizedBox.shrink();
                  },
                ),
              ),
              )
            ],
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => ChatScreen(
                    senderId: widget.senderId,
                    recipientId: widget.recipientId,
                    senderAvatar: widget.userPhoto,
                    recipientAvatar: widget.userPhoto,
                    nameUser: widget.lastName,
                  ),
                ),
              );
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
              ),
            ),
            child: Text('Отправить сообщение'),
          ),
        ],
      ),
    );
  }




}
