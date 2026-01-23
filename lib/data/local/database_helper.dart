import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:privacy_first_nutrition_tracking_app/data/models/food_entry.dart';
import 'package:privacy_first_nutrition_tracking_app/data/models/user_profile.dart';

/// Database helper for managing SQLite database
/// Handles all CRUD operations for food entries and user profile
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  /// Get database instance, create if doesn't exist
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the SQLite database
  Future<Database> _initDatabase() async {
    // Get the database path
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'nutritrack.db');

    // Open/create the database with version 3
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Create food_entries table
    await db.execute('''
      CREATE TABLE food_entries (
        id TEXT PRIMARY KEY,
        foodName TEXT NOT NULL,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        carbs REAL NOT NULL,
        fat REAL NOT NULL,
        servingSize REAL NOT NULL,
        servingUnit TEXT NOT NULL,
        mealType TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');

    // Create user_profile table
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        height REAL NOT NULL,
        currentWeight REAL NOT NULL,
        targetWeight REAL NOT NULL,
        activityLevel TEXT NOT NULL,
        dailyCalorieGoal REAL NOT NULL,
        dailyProteinGoal REAL NOT NULL,
        dailyCarbsGoal REAL NOT NULL,
        dailyFatGoal REAL NOT NULL,
        dailyWaterGoal REAL NOT NULL,
        healthConditions TEXT,
        allergies TEXT,
        goalType TEXT DEFAULT 'maintenance',
        preferredLanguage TEXT DEFAULT 'en-US'
      )
    ''');

    // Create water_intake table
    await db.execute('''
      CREATE TABLE water_intake (
        date TEXT PRIMARY KEY,
        amount INTEGER NOT NULL
      )
    ''');

    // Create weight_log table
    await db.execute('''
      CREATE TABLE weight_log (
        date TEXT PRIMARY KEY,
        weight REAL NOT NULL
      )
    ''');

    print('Database tables created successfully');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');

    // Migration from version 1 to 2: Add goalType column
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE user_profile ADD COLUMN goalType TEXT DEFAULT 'maintenance'",
      );
      print('Added goalType column to user_profile table');
    }

    // Migration from version 2 to 3: Add preferredLanguage column
    if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE user_profile ADD COLUMN preferredLanguage TEXT DEFAULT 'en-US'",
      );
      print('Added preferredLanguage column to user_profile table');
    }
  }

  // ==================== FOOD ENTRIES ====================

  /// Insert a new food entry
  Future<int> insertFoodEntry(FoodEntry entry) async {
    try {
      final db = await database;
      print('Inserting food entry: ${entry.toJson()}'); // Debug log
      final result = await db.insert('food_entries', {
        'id': entry.id,
        'foodName': entry.name,
        'calories': entry.calories,
        'protein': entry.protein,
        'carbs': entry.carbs,
        'fat': entry.fat,
        'servingSize': entry.servingSize,
        'servingUnit': entry.servingUnit,
        'mealType': entry.mealType,
        'timestamp': entry.timestamp.millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      print('Food entry inserted with id: $result'); // Debug log
      return result;
    } catch (e) {
      print('Error inserting food entry: $e');
      rethrow;
    }
  }

  /// Get all food entries
  Future<List<FoodEntry>> getFoodEntries() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'food_entries',
        orderBy: 'timestamp DESC',
      );

      return List.generate(maps.length, (i) {
        return FoodEntry(
          id: maps[i]['id'] as String,
          name: maps[i]['foodName'] as String,
          calories: maps[i]['calories'] is int
              ? (maps[i]['calories'] as int).toDouble()
              : maps[i]['calories'] as double,
          protein: maps[i]['protein'] is int
              ? (maps[i]['protein'] as int).toDouble()
              : maps[i]['protein'] as double,
          carbs: maps[i]['carbs'] is int
              ? (maps[i]['carbs'] as int).toDouble()
              : maps[i]['carbs'] as double,
          fat: maps[i]['fat'] is int
              ? (maps[i]['fat'] as int).toDouble()
              : maps[i]['fat'] as double,
          servingSize: maps[i]['servingSize'] is int
              ? (maps[i]['servingSize'] as int).toDouble()
              : maps[i]['servingSize'] as double,
          servingUnit: maps[i]['servingUnit'] as String,
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            maps[i]['timestamp'] as int,
          ),
          mealType: maps[i]['mealType'] as String,
        );
      });
    } catch (e) {
      print('Error getting food entries: $e');
      return [];
    }
  }

  /// Get food entries for a specific date range
  Future<List<FoodEntry>> getFoodEntriesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'food_entries',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      map['timestamp'] = DateTime.fromMillisecondsSinceEpoch(map['timestamp']);
      return FoodEntry.fromJson(map);
    });
  }

  /// Update a food entry
  Future<int> updateFoodEntry(FoodEntry entry) async {
    final db = await database;
    return await db.update(
      'food_entries',
      entry.toJson()..['timestamp'] = entry.timestamp.millisecondsSinceEpoch,
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  /// Delete a food entry
  Future<int> deleteFoodEntry(String id) async {
    final db = await database;
    return await db.delete('food_entries', where: 'id = ?', whereArgs: [id]);
  }

  /// Delete all food entries
  Future<int> deleteAllFoodEntries() async {
    final db = await database;
    return await db.delete('food_entries');
  }

  // ==================== USER PROFILE ====================

  /// Save or update user profile
  Future<int> saveUserProfile(UserProfile profile) async {
    try {
      final db = await database;
      final profileMap = profile.toJson();
      profileMap['id'] = 1; // Always use ID 1 for single user profile

      // Convert lists to comma-separated strings
      profileMap['healthConditions'] = profile.healthConditions.join(',');
      profileMap['allergies'] = profile.allergies.join(',');

      print('Saving profile: $profileMap'); // Debug log

      final result = await db.insert(
        'user_profile',
        profileMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('Profile saved successfully, result: $result'); // Debug log
      return result;
    } catch (e) {
      print('Error saving profile to database: $e');
      rethrow;
    }
  }

  /// Get user profile
  Future<UserProfile?> getUserProfile() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'user_profile',
        where: 'id = ?',
        whereArgs: [1],
      );

      if (maps.isEmpty) return null;

      final map = Map<String, dynamic>.from(maps.first);

      // Parse the comma-separated strings back to lists
      map['healthConditions'] =
          (map['healthConditions'] as String?)
              ?.split(',')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [];
      map['allergies'] =
          (map['allergies'] as String?)
              ?.split(',')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [];

      // Handle null preferredLanguage (for older profiles)
      map['preferredLanguage'] = map['preferredLanguage'] ?? 'en-US';

      return UserProfile.fromJson(map);
    } catch (e) {
      print('Error loading profile from database: $e');
      return null;
    }
  }

  /// Delete user profile
  Future<int> deleteUserProfile() async {
    final db = await database;
    return await db.delete('user_profile', where: 'id = ?', whereArgs: [1]);
  }

  // ==================== WATER INTAKE ====================

  /// Save water intake for a specific date
  Future<int> saveWaterIntake(String date, int amount) async {
    final db = await database;
    return await db.insert('water_intake', {
      'date': date,
      'amount': amount,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get water intake for a specific date
  Future<int?> getWaterIntake(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'water_intake',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (maps.isEmpty) return null;
    return maps.first['amount'] as int;
  }

  /// Get all water intake records
  Future<Map<String, int>> getAllWaterIntake() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('water_intake');

    final Map<String, int> waterData = {};
    for (final map in maps) {
      waterData[map['date'] as String] = map['amount'] as int;
    }
    return waterData;
  }

  /// Delete water intake for a specific date
  Future<int> deleteWaterIntake(String date) async {
    final db = await database;
    return await db.delete(
      'water_intake',
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  // ==================== WEIGHT LOG ====================

  /// Save weight for a specific date
  Future<int> saveWeight(String date, double weight) async {
    final db = await database;
    return await db.insert('weight_log', {
      'date': date,
      'weight': weight,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get weight for a specific date
  Future<double?> getWeight(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'weight_log',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (maps.isEmpty) return null;
    return maps.first['weight'] as double;
  }

  /// Get all weight records
  Future<Map<String, double>> getAllWeights() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'weight_log',
      orderBy: 'date ASC',
    );

    final Map<String, double> weightData = {};
    for (final map in maps) {
      weightData[map['date'] as String] = map['weight'] as double;
    }
    return weightData;
  }

  /// Delete weight log for a specific date
  Future<int> deleteWeight(String date) async {
    final db = await database;
    return await db.delete('weight_log', where: 'date = ?', whereArgs: [date]);
  }

  // ==================== DATABASE MANAGEMENT ====================

  /// Clear all data from all tables
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('food_entries');
    await db.delete('user_profile');
    await db.delete('water_intake');
    await db.delete('weight_log');
    print('All data cleared from database');
  }

  /// Close the database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Get database statistics
  Future<Map<String, int>> getDatabaseStats() async {
    final db = await database;

    final foodCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM food_entries'),
        ) ??
        0;

    final waterCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM water_intake'),
        ) ??
        0;

    final weightCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM weight_log'),
        ) ??
        0;

    return {
      'food_entries': foodCount,
      'water_records': waterCount,
      'weight_records': weightCount,
    };
  }
}
