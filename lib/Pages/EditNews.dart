import 'package:flutter/material.dart';

import '../Models/NewsService.dart';

class EditNews extends StatefulWidget {
  final int newsId;
  final String initialDescription;

  const EditNews({
    Key? key,
    required this.newsId,
    required this.initialDescription,
  }) : super(key: key);

  @override
  _EditNewsState createState() => _EditNewsState();
}

class _EditNewsState extends State<EditNews> {
  TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.initialDescription;
  }

  Future<void> _saveChanges() async {
    try {
      // Предполагается, что метод editNews успешно обновляет новость на сервере
      await NewsService().editNews(
        newsId: widget.newsId,
        newDescription: _descriptionController.text,
      );

      // Если сохранение прошло успешно, возвращаем обновленное описание и закрываем экран
      Navigator.pop(context, _descriptionController.text);
    } catch (e) {
      print('Error saving changes: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Редактировать новость'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Описание новости',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Сохранить изменения'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                ),
                // Дополнительные стили кнопки, если необходимо
              ),
            ),
          ],
        ),
      ),
    );
  }
}
