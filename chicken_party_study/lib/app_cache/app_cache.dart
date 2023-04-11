import 'package:get_storage/get_storage.dart';

class AppCache {
  static final box = GetStorage();
  static String userNickname = '';

  static Future<void> writeCacheisLoggedin() async {
    await box.write('isloggedin', true);
  }

  static Future<void> deleteCacheisLoggedin() async {
    await box.write('isloggedin', false);
  }

  static bool getCachedisLoggedin() {
    if (box.read<bool>('isloggedin') == true) {
      return true;
    } else if (box.read<bool>('isloggedin') == false) {
      return false;
    } else {
      return false;
    }
  }

  static void writeUserNickname(value) {
    box.write(userNickname, value);
  }

  static String getUserNickname() {
    final value = box.read(userNickname);
    return value;
  }

  static void eraseAllCache() {
    box.erase();
  }
}
