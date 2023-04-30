import 'package:chicken_party_study/app_cache/app_cache.dart';
import 'package:chicken_party_study/views/home_screen/home.dart';
import 'package:chicken_party_study/views/login_screen/login_screen.dart';
import 'package:chicken_party_study/views/profile_screen/public_profile_screen.dart';
import 'package:chicken_party_study/views/splash_screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      getPages: [
        GetPage(
            name: '/',
            page: () => Home(
                  isloggedin: AppCache.getCachedisLoggedin(),
                )),
        GetPage(
            name: '/login',
            page: () => const LoginScreen(
                  isloggedin: false,
                )),
        GetPage(
            name: '/public-profile', page: () => const PublicProfileScreen()),
      ],
    );
  }
}
