import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Configures the IndexedDB-backed SQLite implementation for Flutter Web.
void initializeDatabase() {
  databaseFactory = databaseFactoryFfiWeb;
}
