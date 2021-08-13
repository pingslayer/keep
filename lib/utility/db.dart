import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseManager {

  static final _dbName = 'keep.db';
  static final _dbVersion = 1;
  static final _recordsTable = 'records';
  static final _holdingsTable = 'holdings';
  static final _transactionsTable = 'transactions';
  static final _syncTable = 'sync';

  DatabaseManager._privateConstructor();
  static final DatabaseManager instance = DatabaseManager._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if(_database != null)
      return _database;

    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, _dbName);
    await deleteDatabase(path);
    _database = await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
    _database.insert(_holdingsTable, {'id':1,'value': 0});
    _database.insert(_syncTable, {'id':1,'value': 0});
    return _database;
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE $_recordsTable (
        id INTEGER PRIMARY KEY, 
        deed INTEGER NOT NULL, 
        created_at VARCHAR(255), 
        status INTEGER NOT NULL);
      '''
    );
    await db.execute(
        '''
      CREATE TABLE $_holdingsTable (
        id INTEGER NOT NULL, 
        value INTEGER NOT NULL);
      '''
    );
    await db.execute(
        '''
      CREATE TABLE $_syncTable (
        id INTEGER NOT NULL, 
        value INTEGER NOT NULL);
      '''
    );
    await db.execute(
        '''
      CREATE TABLE $_transactionsTable (
        id INTEGER PRIMARY KEY, 
        holding INTEGER NOT NULL,
        deeds INTEGER NOT NULL,
        direction INTEGER NOT NULL, 
        created_at VARCHAR(255), 
        status INTEGER NOT NULL);
      '''
    );
  }

  //record ops

  Future<int> insertRecord(Map<String,dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(_recordsTable, row);
  }

  Future<List<Map<String,dynamic>>> queryAllRecords() async {
    Database db = await instance.database;
    return await db.query(_recordsTable);
  }

  Future<int> getRecordsCountByDeedActive(int deed) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $_recordsTable where deed = $deed and status = 1'));
  }

  Future<int> updateAllRecordsStatus(int status) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('UPDATE $_recordsTable SET status = $status'));
  }

  // holdings ops

  Future<int> getHoldingsValue() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT value FROM $_holdingsTable where id = 1'));
  }

  Future<int> updateHoldings(int deeds) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('UPDATE $_holdingsTable SET value = value + $deeds WHERE id = 1'));
  }

  Future<List<Map<String,dynamic>>> queryAllHoldings() async {
    Database db = await instance.database;
    return await db.query(_holdingsTable);
  }

  // transactions ops

  Future<int> insertTransaction(Map<String,dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(_transactionsTable, row);
  }

  Future<List<Map<String,dynamic>>> queryAllTransactions() async {
    Database db = await instance.database;
    return await db.query(_transactionsTable);
  }

  Future<List<Map<String,dynamic>>> queryAllTransactionsDescOrder() async {
    Database db = await instance.database;
    return await db.query(_transactionsTable, orderBy: "id DESC");
  }

  // sync ops

  Future<int> getSyncValue() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT value FROM $_syncTable where id = 1'));
  }

  Future<int> increaseSyncValue() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('UPDATE $_syncTable SET value = value + 1 WHERE id = 1'));
  }

  Future<void> updateSyncValue(value) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('UPDATE $_syncTable SET value = $value WHERE id = 1'));
  }

}