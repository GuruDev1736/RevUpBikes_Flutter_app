import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/bike_model.dart';
import '../models/place_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bookmarks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY,
        bikeName TEXT NOT NULL,
        bikeModel TEXT NOT NULL,
        brand TEXT NOT NULL,
        bikeImage TEXT NOT NULL,
        description TEXT NOT NULL,
        pricePerHour REAL NOT NULL,
        pricePerDay REAL NOT NULL,
        pricePerWeek REAL NOT NULL,
        pricePerMonth REAL NOT NULL,
        placeId INTEGER NOT NULL,
        placeName TEXT NOT NULL,
        placeDescription TEXT NOT NULL,
        placeImage TEXT NOT NULL,
        placeLocation TEXT NOT NULL,
        category TEXT NOT NULL,
        engineCapacity INTEGER NOT NULL,
        fuelType TEXT NOT NULL,
        transmission TEXT NOT NULL,
        status TEXT NOT NULL,
        registrationNumber TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        bookmarkedAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new price columns
      await db.execute(
        'ALTER TABLE bookmarks ADD COLUMN pricePerWeek REAL NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE bookmarks ADD COLUMN pricePerMonth REAL NOT NULL DEFAULT 0',
      );
    }
  }

  // Add bookmark
  Future<int> addBookmark(BikeModel bike) async {
    final db = await database;

    // Check if already bookmarked
    final existing = await db.query(
      'bookmarks',
      where: 'id = ?',
      whereArgs: [bike.id],
    );

    if (existing.isNotEmpty) {
      return bike.id; // Already bookmarked
    }

    return await db.insert('bookmarks', {
      'id': bike.id,
      'bikeName': bike.bikeName,
      'bikeModel': bike.bikeModel,
      'brand': bike.brand,
      'bikeImage': bike.bikeImage,
      'description': bike.description,
      'pricePerHour': bike.pricePerHour,
      'pricePerDay': bike.pricePerDay,
      'pricePerWeek': bike.pricePerWeek,
      'pricePerMonth': bike.pricePerMonth,
      'placeId': bike.place.id,
      'placeName': bike.place.placeName,
      'placeDescription': bike.place.placeDescription,
      'placeImage': bike.place.placeImage,
      'placeLocation': bike.place.placeLocation,
      'category': bike.category,
      'engineCapacity': bike.engineCapacity,
      'fuelType': bike.fuelType,
      'transmission': bike.transmission,
      'status': bike.status,
      'registrationNumber': bike.registrationNumber,
      'createdAt': bike.createdAt.toIso8601String(),
      'updatedAt': bike.updatedAt.toIso8601String(),
      'bookmarkedAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Remove bookmark
  Future<int> removeBookmark(int bikeId) async {
    final db = await database;
    return await db.delete('bookmarks', where: 'id = ?', whereArgs: [bikeId]);
  }

  // Check if bike is bookmarked
  Future<bool> isBookmarked(int bikeId) async {
    final db = await database;
    final result = await db.query(
      'bookmarks',
      where: 'id = ?',
      whereArgs: [bikeId],
    );
    return result.isNotEmpty;
  }

  // Get all bookmarks
  Future<List<BikeModel>> getAllBookmarks() async {
    final db = await database;
    final result = await db.query('bookmarks', orderBy: 'bookmarkedAt DESC');

    return result.map((json) => _bikeFromJson(json)).toList();
  }

  // Clear all bookmarks
  Future<int> clearAllBookmarks() async {
    final db = await database;
    return await db.delete('bookmarks');
  }

  // Convert database map to BikeModel
  BikeModel _bikeFromJson(Map<String, dynamic> json) {
    return BikeModel(
      id: json['id'] as int,
      bikeName: json['bikeName'] as String,
      bikeModel: json['bikeModel'] as String,
      brand: json['brand'] as String,
      bikeImage: json['bikeImage'] as String,
      description: json['description'] as String,
      pricePerHour: json['pricePerHour'] as double,
      pricePerDay: json['pricePerDay'] as double,
      pricePerWeek: json['pricePerWeek'] as double,
      pricePerMonth: json['pricePerMonth'] as double,
      place: Place(
        id: json['placeId'] as int,
        placeName: json['placeName'] as String,
        placeDescription: json['placeDescription'] as String,
        placeImage: json['placeImage'] as String,
        placeLocation: json['placeLocation'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      ),
      category: json['category'] as String,
      engineCapacity: json['engineCapacity'] as int,
      fuelType: json['fuelType'] as String,
      transmission: json['transmission'] as String,
      status: json['status'] as String,
      registrationNumber: json['registrationNumber'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
