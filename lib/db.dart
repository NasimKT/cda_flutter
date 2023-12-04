import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String? path = await getDatabasesPath();

    if (path != null) {
      path = join(path, 'Database.db');

      return openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
          CREATE TABLE EmergencyContacts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            phone TEXT
          )
        ''');
        },
      );
    } else {
      // Handle the case where the database path is null, e.g., show an error message.
      throw Exception("Failed to get the database path.");
    }
  }

  Future<int> insertEmergencyContact(String phone) async {
    Database db = await database;
    Map<String, dynamic> contact = {'phone': phone};
    return await db.insert('EmergencyContacts', contact);
  }

  Future<List<Map<String, dynamic>>> getAllEmergencyContacts() async {
    Database db = await database;
    return await db.query('EmergencyContacts');
  }

  // Add more methods for updating, deleting, and querying as needed
}
