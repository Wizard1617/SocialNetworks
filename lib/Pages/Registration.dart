import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_network/Pages/Auth.dart';
import 'package:social_network/Provider/SettingsPage.dart';

import '../Api/ApiRequest.dart';


TextEditingController _firstNameController = TextEditingController();
TextEditingController _lastNameController = TextEditingController();
TextEditingController _loginController = TextEditingController();
TextEditingController _passwordController = TextEditingController();

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  bool _isObscure = true;

  void _toggleObscure() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  void _navigateToAuthorization(BuildContext context) {
    Navigator.pop(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(seconds: 1),
        pageBuilder: (context, animation, secondaryAnimation) => Settings(), // Замените PreviousScreen() на ваш предыдущий экран
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.elasticInOut,
          ).drive(Tween<double>(begin: 0.0, end: 1.0)); // Используем Tween для обратного эффекта

          return ScaleTransition(
            alignment: Alignment.center,
            scale: curvedAnimation,
            child: child,
          );
        },
      ),
    );
  }


  void _showLoginMessage(String text) {
    final snackBar = SnackBar(
      content: Text(text,
        textAlign: TextAlign.center ,
      ),
      backgroundColor: Colors.green,  // Измените цвет фона
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 80.0, left: 40.0, right: 40.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      /* padding: const EdgeInsets.fromLTRB(90.0, 16.0, 16.0, 0.0), // Внутренний отступ для поднятия*/
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        /* backgroundColor: const Color.fromRGBO(44, 47, 47, 100),*/
        body: Stack(
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[700]?.withOpacity(0.2), // Задаем зеленый цвет
                  borderRadius: BorderRadius.circular(30.0), // Закругляем края
                ),
                height: 500, // Задаем высоту прямоугольника
                width: 420, // Задаем ширину прямоугольника
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20, left: 25),
              child: OutlinedButton(
                onPressed: () => _navigateToAuthorization(context),
                style: ButtonStyle(
                  side: MaterialStateProperty.all(
                    const BorderSide(
                      color: Colors.deepOrangeAccent,
                      width: 1.0,
                    ),
                  ),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Здесь указываем цвет текста
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.deepOrangeAccent),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0), // Здесь устанавливаем радиус закругления
                    ),
                  ),// Здесь указываем цвет текста

                ),
                child: Icon(Icons.arrow_back),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20, right: 25),
              child: Align(
                alignment: Alignment.topRight,
                child: Text(
                  '⌞Ai⌝',
                  style: TextStyle(
                    fontSize: 25.0,
                    color: Colors.deepOrangeAccent,
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _firstNameController, // Контроллер для поля фамилии
                      decoration: InputDecoration(
                        hintText: 'Введите фамилию',
                        labelText: 'Фамилия',
                        prefixIcon: const Icon(Icons.person),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.deepOrangeAccent, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        hintStyle: const TextStyle(color: Colors.blue),
                        contentPadding: const EdgeInsets.all(12.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _lastNameController, // Контроллер для поля имени
                      decoration: InputDecoration(
                        hintText: 'Введите имя',
                        labelText: 'Имя',
                        prefixIcon: const Icon(Icons.person),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.deepOrangeAccent, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        hintStyle: const TextStyle(color: Colors.blue),
                        contentPadding: const EdgeInsets.all(12.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _loginController, // Контроллер для поля логина
                      decoration: InputDecoration(
                        hintText: 'Введите логин',
                        labelText: 'Логин',
                        prefixIcon: const Icon(Icons.alternate_email),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.deepOrangeAccent, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        hintStyle: const TextStyle(color: Colors.blue),
                        contentPadding: const EdgeInsets.all(12.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _passwordController, // Контроллер для поля пароля
                      obscureText: _isObscure,
                      decoration: InputDecoration(
                        hintText: 'Введите пароль',
                        labelText: 'Пароль',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: GestureDetector(
                          onTap: _toggleObscure,
                          child: Icon(
                            _isObscure ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.deepOrangeAccent, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        hintStyle: const TextStyle(color: Colors.blue),
                        contentPadding: const EdgeInsets.all(12.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      obscureText: _isObscure,
                      decoration: InputDecoration(
                        hintText: 'Подтввердите пароль',
                        labelText: 'Подтверждение пароля',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: GestureDetector(
                          onTap: _toggleObscure,
                          child: Icon(
                            _isObscure ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.deepOrangeAccent, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        hintStyle: const TextStyle(color: Colors.blue),
                        contentPadding: const EdgeInsets.all(12.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    onPressed: () {
                      registration(_firstNameController.text, _lastNameController.text, _loginController.text, _passwordController.text);

                      _showLoginMessage('Регистрация выполнена');
                      /* showCustomSnackBar(context, 'Вход выполнен');*/
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.deepOrangeAccent),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0), // Здесь устанавливаем радиус закругления
                        ),
                      ),
                      //backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                      side: MaterialStateProperty.all(
                        const BorderSide(
                          color: Colors.deepOrangeAccent,  // Set the border color to pink
                          width: 1.0,
                          // Set the border width
                        ),
                      ),
                    ),
                    child: const Text('Зарегистрироваться',
                      style: TextStyle(
                      ),),
                  ),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}