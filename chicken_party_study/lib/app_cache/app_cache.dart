import 'package:get_storage/get_storage.dart';

class AppCache {
  static final box = GetStorage();

  static Future<void> saveCacheisLoggedin() async {
    await box.write('isloggedin', true);
  }

  static Future<void> delCacheisLoggedin() async {
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
}
