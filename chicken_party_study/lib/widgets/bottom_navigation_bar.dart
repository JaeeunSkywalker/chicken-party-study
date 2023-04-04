import 'package:chicken_patry_study/app_cache/app_cache.dart';
import 'package:chicken_patry_study/consts/colors.dart';
import 'package:chicken_patry_study/views/profile_screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  int currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      currentIndex = index;
      if (currentIndex == 2) {
        // "내 프로필" 버튼을 눌렀을 때
        if (AppCache.getCachedisLoggedin() == true) {
          // 로그인이 되어 있으면
          Get.to(() => const ProfileScreen()); // ProfileScreen으로 이동
        } else {
          // 로그인이 되어 있지 않으면
          Get.snackbar(
            '로그인 필요', // 타이틀
            '로그인을 해 주세요', // 메시지
            duration: const Duration(seconds: 1), // Snackbar가 보일 시간
            snackPosition: SnackPosition.BOTTOM, // Snackbar 위치
            backgroundColor: white,
          ); // LoginScreen으로 이동
        }
      }
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
      currentIndex: currentIndex,
      selectedItemColor: widget.selectedItemColor ?? Colors.blue,
      unselectedItemColor: widget.unselectedItemColor ?? Colors.grey,
    );
  }
}
