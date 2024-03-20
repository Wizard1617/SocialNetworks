import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Api/ApiRequest.dart';
import '../Pages/Auth.dart';
import 'ThemeProvider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  void logout() async {
    // Очищаем данные о пользователе (SharedPreferences, если используются)
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Это удалит все данные из SharedPreferences
    IDUser = '';
    // Используем pushAndRemoveUntil для того, чтобы перейти на экран авторизации и очистить стек навигации
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Authorization()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: Colors.deepOrangeAccent,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              themeProvider.getTheme().brightness == Brightness.dark ? Icons.dark_mode : Icons.light_mode,
              size: 30, // Увеличиваем размер иконки
            ),
            onPressed: () {
              if (themeProvider.getTheme().brightness == Brightness.dark) {
                themeProvider.setLightTheme();
              } else {
                themeProvider.setDarkTheme();
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Другие элементы интерфейса
            ElevatedButton(
              onPressed: () {
                logout();
              },
              child: const Text('Выход'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
