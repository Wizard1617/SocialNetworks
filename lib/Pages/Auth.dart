import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/User.dart';
import '../Api/ApiRequest.dart';
import 'Navigation.dart';
import 'Registration.dart';

TextEditingController _firstNameController = TextEditingController();
TextEditingController _lastNameController = TextEditingController();
TextEditingController _loginController = TextEditingController();
TextEditingController _passwordController = TextEditingController();

class Authorization extends StatefulWidget {
  const Authorization({super.key});

  @override
  State<Authorization> createState() => _AuthorizationState();
}

class _AuthorizationState extends State<Authorization> {
  bool _isObscure = true;
  late User user;

  Future<dynamic> fillUserDataByUserId() async {
    try {
      // Ваш существующий код для выполнения запроса
      final response = await dio.get('$api/Users/$IDUser');
      if (response.statusCode == 200) {
        final userData =
            response.data; // Получение данных пользователя из response.data

        user = User(
          id: userData['idUser'],
          firstName: userData['firstName'],
          lastName: userData['lastName'],
          loginUser: userData['loginUser'],
          // Добавьте остальные поля
        );

        // Здесь вы можете сделать что-то с объектом user, например, сохранить его в переменной класса _AuthorizationState
      } else {
        // Обработка ошибки или отображение заглушки
      }
    } catch (e) {
      throw Exception('Ошибка при выполнении запроса: $e');
    }
  }

  void _toggleObscure() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  void _showLoginMessage(String text) async {
    final snackBar = SnackBar(
        content: Text(
          text,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 80.0, left: 40.0, right: 40.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    if (text == 'Вход выполнен') {
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);
      prefs.setInt('userId', user.id);
      prefs.setString('firstName', user.firstName);
      prefs.setString('lastName', user.lastName);
      prefs.setString('loginUser', user.loginUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[700]?.withOpacity(0.2), // Задаем зеленый цвет
                  borderRadius: BorderRadius.circular(30.0), // Закругляем края
                ),
                height: 300, // Задаем высоту прямоугольника
                width: 420, // Задаем ширину прямоугольника
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Align(
                alignment: Alignment.topRight,
                child: Text(
                  "⌞Ai⌝",
                  style: TextStyle(
                    fontSize: 35.0,
                    color: Colors.deepOrangeAccent,
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double textFieldWidth = constraints.maxWidth * 0.3;
                      if (MediaQuery.of(context).size.width < 600) {
                        // Увеличиваем ширину для мобильных устройств
                        textFieldWidth = constraints.maxWidth * 1;
                      }
                      return Container(
                        width: textFieldWidth,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            controller: _loginController,
                            decoration: InputDecoration(
                              hintText: 'Введите логин',
                              labelText: 'Логин',
                              prefixIcon: const Icon(Icons.alternate_email),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                    color: Colors.deepOrangeAccent, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                    color: Colors.blue, width: 2.0),
                              ),
                              hintStyle: const TextStyle(color: Colors.blue),
                              contentPadding: const EdgeInsets.all(12.0),
                            ),
                            onSubmitted: (_) {
                              _login();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double textFieldWidth = constraints.maxWidth * 0.3;
                      if (MediaQuery.of(context).size.width < 600) {
                        // Увеличиваем ширину для мобильных устройств
                        textFieldWidth = constraints.maxWidth * 1;
                      }
                      return Container(
                        width: textFieldWidth,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _isObscure,
                            decoration: InputDecoration(
                              hintText: 'Введите пароль',
                              labelText: 'Пароль',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: GestureDetector(
                                onTap: _toggleObscure,
                                child: Icon(
                                  _isObscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                    color: Colors.deepOrangeAccent, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                    color: Colors.blue, width: 2.0),
                              ),
                              hintStyle: const TextStyle(color: Colors.blue),
                              contentPadding: const EdgeInsets.all(12.0),
                            ),
                            onSubmitted: (_) {
                              _login();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  OutlinedButton(
                    onPressed: () {
                      _login();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.deepOrangeAccent),
                      side: MaterialStateProperty.all(
                        const BorderSide(
                          color: Colors.deepOrangeAccent,
                          width: 1.0,
                        ),
                      ),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Здесь указываем цвет текста
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0), // Здесь устанавливаем радиус закругления
                        ),
                      ),
                    ),
                    child: const Text(
                      'Войти',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration(seconds: 2),
                          pageBuilder: (context, animation, secondaryAnimation) => Registration(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            var curvedAnimation = CurvedAnimation(
                              parent: animation,
                              curve: Curves.elasticInOut,
                            );
                            return ScaleTransition(
                              alignment: Alignment.center,
                              scale: curvedAnimation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child: const Text(
                      'Зарегистрироваться',
                      style: TextStyle(
                        color: Colors.deepOrangeAccent, // Устанавливаем белый цвет текста
                      ),
                    ),
                  ),


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    await request(_loginController.text, _passwordController.text);
    await getID(_loginController.text);
    await fillUserDataByUserId();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
    prefs.setInt('userId', user.id);
    prefs.setString('firstName', user.firstName);
    prefs.setString('lastName', user.lastName);
    prefs.setString('loginUser', user.loginUser);
    _showLoginMessage('Вход выполнен');
    print("Login function executed");

    user = await getUserInfoFromSharedPreferences();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => NavigationScreen(user: user),
        fullscreenDialog: false, // Этот параметр скроет кнопку "назад"
      ),
    );
  }
}

Future<User> getUserInfoFromSharedPreferences() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Здесь предполагается, что информация о пользователе была сохранена в SharedPreferences
  final int userId =
      prefs.getInt('userId') ?? 0; // Замените на ключ, который вы использовали
  IDUser = prefs.getInt('userId').toString() ??
      0.toString(); // Замените на ключ, который вы использовали
  final String firstName = prefs.getString('firstName') ?? '';
  final String lastName = prefs.getString('lastName') ?? '';
  final String loginUser = prefs.getString('loginUser') ?? '';

  return User(
    id: userId,
    firstName: firstName,
    lastName: lastName,
    loginUser: loginUser,
    // Добавьте остальные поля пользователя
  );
}
