import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: <Widget>[
          Theme(
            data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            child: TabBar(
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.deepOrangeAccent,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'Кнопка 1'),
                Tab(text: 'Кнопка 2'),
                Tab(text: 'Кнопка 3'),
              ],
              labelPadding: EdgeInsets.zero,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                Center(child: Text('Содержимое 1')),
                Center(child: Text('Содержимое 2')),
                Center(child: Text('Содержимое 3')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
