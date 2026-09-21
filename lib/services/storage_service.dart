import 'package:shared_preferences/shared_preferences.dart';
import '../data/datasources/local_storage_data_source.dart';

/// Storage initialization service
class StorageService {
  static late final SharedPreferences preferences;
  static late final LocalStorageDataSource localStorage;

  static Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
    localStorage = LocalStorageDataSource(preferences);
  }
}
