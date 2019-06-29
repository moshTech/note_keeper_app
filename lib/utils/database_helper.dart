import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:note_keeper_app/model/note.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  // Named constructor to create instance of DatabaseHelper
  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null)
      // This is executed only once, singleton object
      _databaseHelper = DatabaseHelper._createInstance();

    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) _database = await initializeDatabase();

    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    // Open or create the database at a given path
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$colTitle TEXT, $colDescription TEXT, $colPriority Integer, $colDate Text)');
  }

  // Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;

    var result = await db.query(noteTable, orderBy: '$colPriority DESC');
    return result;
  }

  // Insert Operation: Insert a note objec to database
  Future<int> insertNote(Note note) async {
    Database db = await this.database;

    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  // Update Operation: Update a note object and save it to database
  Future<int> updateNote(Note note) async {
    Database db = await this.database;

    var result = await db.update(noteTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  // Delete Operation: Delete a note object from database
  Future<int> deleteNote(int id) async {
    Database db = await this.database;

    int result = await db.delete(noteTable, where: '$colId = $id');
    return result;
  }

  //Get number of note objects in database
  Future<int> getCount() async {
    Database db = await this.database;

    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' {List<Map> } and convert it to 'Note List' { List<Note> }
  Future<List<Note>> getNoteList() async {
    
    var noteMapList = await getNoteMapList(); // Get 'Map List' from database
    int count =
        noteMapList.length; // Count the number of map entries in db table

    List<Note> noteList = List<Note>();
    // For loop to create a 'Note List' from a 'Map List'
    for (var i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }
}
