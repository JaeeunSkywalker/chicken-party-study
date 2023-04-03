import 'package:chicken_patry_study/consts/colors.dart';
import 'package:flutter/material.dart';

class MainBottomNavigationBar extends StatefulWidget {
  final List<BottomNavigationBarItem> items;
  final MaterialColor? selectedItemColor;
  final MaterialColor? unselectedItemColor;

  const MainBottomNavigationBar({
    Key? key,
    required this.items,
    this.selectedItemColor,
    this.unselectedItemColor,
  }) : super(key: key);

  @override
  MainBottomNavigationBarState createState() => MainBottomNavigationBarState();
}

class MainBottomNavigationBarState extends State<MainBottomNavigationBar> {
  // ignore: unused_field
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<BottomNavigationBarItem> items = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: '홈',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: '검색',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: '내 프로필',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: black,
      items: widget.items,
      onTap: _onItemTapped,
      currentIndex: _currentIndex,
      selectedItemColor: widget.selectedItemColor ?? Colors.blue,
      unselectedItemColor: widget.unselectedItemColor ?? Colors.grey,
    );
  }
}
