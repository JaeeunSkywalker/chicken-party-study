import 'package:get_storage/get_storage.dart';

class AppCache {
  static final box = GetStorage();

  static Future<void> saveCacheisLoggedin(bool value) async {
    await box.write('isLoggedin', value);
  }

  static Future<void> delCacheisLoggedin(bool value) async {
    await box.write('isLoggedin', value);
  }

  static bool getCachedisLoggedin() {
    if (box.read<bool>('isLoggedin') == true) {
      return true;
    } else if (box.read<bool>('isLoggedin') == false) {
      return false;
    } else {
      return false;
    }
  }
}
