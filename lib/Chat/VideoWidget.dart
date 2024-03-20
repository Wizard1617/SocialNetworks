import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final String url;

  VideoWidget({Key? key, required this.url}) : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {}); // обновление состояния для перерисовки виджета
        _controller.play(); // автоматическое воспроизведение видео после инициализации
      });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _controller.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Инициализация завершена
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            // Используйте Stack для наложения элементов управления на видео
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                VideoPlayer(_controller),
                _ControlsOverlay(controller: _controller),
                VideoProgressIndicator(_controller, allowScrubbing: true),
              ],
            ),
          );
        } else {
          // Инициализация ещё не завершена
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Очистка контроллера при удалении виджета из дерева
    super.dispose();
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key? key, required this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 50),
      reverseDuration: Duration(milliseconds: 200),
      child: controller.value.isPlaying
          ? SizedBox.shrink() // Если видео играет, скрываем кнопки
          : Container(
        color: Colors.black26,
        child: Center(
          child: GestureDetector(
            onTap: () {
              controller.play(); // Воспроизведение видео при нажатии на область экрана
            },
            child: Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 100.0,
              semanticLabel: 'Play',
            ),
          ),
        ),
      ),
    );
  }
}
