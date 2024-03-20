import 'package:flutter/material.dart';

class AchievementsTab extends StatelessWidget {
  final List<Map<String, String>> achievements = [
    {
      "image": "assets/images/Bronze.png",
      "caption": "Отправить 100 сообщений",
    },
    {
      "image": "assets/images/Silver.png",
      "caption": "Отправить 1000 сообщений",
    },
    {
      "image": "assets/images/Gold.png",
      "caption": "Отправить 5000 сообщений",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Количество колонок
        crossAxisSpacing: 10, // Горизонтальное пространство между карточками
        mainAxisSpacing: 10, // Вертикальное пространство между карточками
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return Column(
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10), // Закругление углов
                child: Image.asset(
                  achievements[index]["image"]!,
                  fit: BoxFit.cover, // Масштабирует изображение так, чтобы оно заполнило контейнер
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                achievements[index]["caption"]!,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      },
    );
  }
}
