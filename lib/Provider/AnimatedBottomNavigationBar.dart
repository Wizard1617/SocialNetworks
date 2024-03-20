import 'package:flutter/material.dart';

class CustomFloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;

  CustomFloatingNavBar({
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50.0),
      child: Container(
        height: 70,
        width: 400, // Высота навигационной панели
        color: Colors.grey[700]?.withOpacity(0.4),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildTabItem(index: 0, icon: Icons.article),
              _buildTabItem(index: 1, icon: Icons.message),
              _buildTabItem(index: 2, icon: Icons.account_circle),
              _buildTabItem(index: 3, icon: Icons.people),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
  }) {
    final isSelected = currentIndex == index;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: isSelected ? Colors.deepOrangeAccent : Colors.white,
            size: isSelected ? 30.0 : 20.0,
          ),
          onPressed: () => onItemTapped(index),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 300), // Продолжительность анимации
          width: isSelected ? 24 : 0, // Ширина линии для выбранного элемента и нулевая ширина для не выбранного
          height: 4,
          decoration: BoxDecoration(
            color: Colors.deepOrangeAccent,
            borderRadius: BorderRadius.circular(2.0),
          ),
        ),
      ],
    );
  }
}
