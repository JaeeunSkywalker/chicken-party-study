import 'package:get_storage/get_storage.dart';

class AppCache {
  static final box = GetStorage();
  static String userNickname = '';

  static Future<bool> writeCacheisLoggedin() async {
    await box.write('isloggedin', true);
    return true;
  }

  static Future<bool> deleteCacheisLoggedin() async {
    await box.write('isloggedin', false);
    return false;
  }

  static bool getCachedisLoggedin() {
    if (box.read<bool>('isloggedin') == true) {
      return true;
    } else if (box.read<bool>('isloggedin') == false) {
      return false;
    }
    return false;
  }

  static void writeUserNickname(value) {
    box.write(userNickname, value);
  }

  static String getUserNickname() {
    final value = box.read(userNickname);
    return value;
  }

  static void deleteUserNickname() {
    box.remove(userNickname);
  }
}
