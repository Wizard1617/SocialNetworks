import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:social_network/Api/ApiRequest.dart';

import '../Models/NewsPuctireService.dart';
import '../Models/NewsService.dart';
import '../Models/PictureService.dart';

class AddNews extends StatefulWidget {
  const AddNews({Key? key}) : super(key: key);

  @override
  _AddNewsState createState() => _AddNewsState();
}

class _AddNewsState extends State<AddNews> {
  File? _selectedImage;
  TextEditingController _descriptionController = TextEditingController();

  Future<void> _selectImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final croppedImage = await _cropImage(pickedImage.path);

      if (croppedImage != null) {
        setState(() {
          _selectedImage = croppedImage;
        });
      }
    }
  }

  Future<File?> _cropImage(String imagePath) async {
    final imageCropper = ImageCropper();

    final croppedImage = await imageCropper.cropImage(
      sourcePath: imagePath,
      aspectRatio: CropAspectRatio(
        ratioX: 1, // 1:1 aspect ratio
        ratioY: 1,
      ),
      compressQuality: 100, // Compression quality
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.deepOrange, // Toolbar color
        toolbarWidgetColor: Colors.white, // Toolbar icon color
        statusBarColor: Colors.deepOrange, // Status bar color
        backgroundColor: Colors.white, // Crop background color
      ),
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0,
        aspectRatioLockDimensionSwapEnabled: false,
      ),
    );

    return croppedImage;
  }



  Future<void> _addNews() async {
    try {
      final List<int> bytes = await _selectedImage!.readAsBytes();

      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: 'user_photo.jpg'),
      });

      Response response = await dio.post(
        '$api/Pictures',
        data: formData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Фото успешно загружено. ID фото: ${response.data['idPicture']}');
      } else {
        print('Ошибка при загрузке фото: ${response.statusCode}');
        return;
      }

      int pictureId = response.data['idPicture'];
      DateTime sendingTime = DateTime.now();

      Map<String, dynamic> newsResponse = await NewsService().postNews(
        description: _descriptionController.text,
        likes: 0,
        disLike: 0,
        sendingTime: sendingTime,
        idUser: int.parse(IDUser),
        pictureId: pictureId,
      );

      int newsId = newsResponse['idNews'];

      await NewsPuctireService().postNewsPuctire(
        pictureId: pictureId,
        newsId: newsId,
      );

      // Add any additional logic or UI updates as needed
    } catch (e) {
      print('Error adding news: $e');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить новость'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _selectImage,
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: _selectedImage != null
                    ? Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                )
                    : Icon(Icons.add_a_photo, size: 50),
              ),
            ),
            const SizedBox(height: 16),
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
              onPressed: _addNews,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                ),
                // Дополнительные стили кнопки, если необходимо
              ),
              child: Text('Добавить новость'),
            ),
          ],
        ),
      ),
    );
  }
}
