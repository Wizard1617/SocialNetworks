import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData;

  ThemeProvider(this._themeData);

  ThemeData getTheme() => _themeData;

  setTheme(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  // Функция для установки светлой темы
  void setLightTheme() {
    _themeData = ThemeData.light().copyWith(

      // Определите цвет текста для светлой темы
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
    );
    notifyListeners();
  }

  // Функция для установки темной темы
  void setDarkTheme() {
    _themeData = ThemeData.dark().copyWith(


      // Определите цвет текста для темной темы
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );
    notifyListeners();
  }
}


