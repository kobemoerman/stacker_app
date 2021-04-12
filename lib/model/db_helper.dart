import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stackr/model/studystack.dart';

import 'flashcard.dart';

class DBHelper {
  static final DBHelper _instance = new DBHelper.internal();

  factory DBHelper() => _instance;
  static Database _study;

  DBHelper.internal();

  Future<Database> get db async {
    if (_study == null) _study = await _initDB();

    return _study;
  }

  Future<Database> _initDB() async {
    var path = join(await getDatabasesPath(), 'stack.db');
    return await openDatabase(path, version: 1);
  }

  createStack({String name}) async {
    var client = await db;

    var sql = """CREATE TABLE [$name](
              key INT PRIMARY KEY,
              theme TEXT,
              isSwipped INT,
              question TEXT,
              answer TEXT)""";

    await client.execute(sql);
  }

  dropStack({String name}) async {
    var client = await db;

    var sql = 'DROP TABLE IF EXISTS [$name]';

    await client.execute(sql);
  }

  Future<int> tableLength({String name}) async {
    Database client = await db;

    var sql = 'SELECT COUNT (*) from [$name]';
    var count = await client.rawQuery(sql);

    return Sqflite.firstIntValue(count);
  }

  Future<bool> tableExist({String name}) async {
    Database client = await db;

    var sql = """SELECT * FROM sqlite_master 
              WHERE TYPE = 'table'
              AND name = '$name'""";
    var exist = await client.rawQuery(sql);

    return exist != null && exist.isNotEmpty;
  }

  Future<List<StudyStack>> tableList(String filter) async {
    var client = await db;

    var sql = """SELECT * FROM sqlite_master
              WHERE type = 'table' 
              AND name != 'android_metadata' 
              AND name != 'sqlite_sequence';""";
    var query = (await client.rawQuery(sql)).reversed.toList();

    Iterable<Map<String, dynamic>> list = query;
    if (filter.isNotEmpty) {
      list = query.expand(
        (e) => [
          if ((e['name'] as String)
              .toLowerCase()
              .replaceAll('_', ' ')
              .contains(filter))
            e
        ],
      );
    }

    return Future.wait(list.map((e) async {
      String table = e['name'] as String;
      int cards = await tableLength(name: table);
      return StudyStack(table, cards);
    }));
  }

  Future<List<FlashCard>> cardList({String name}) async {
    Database client = await db;

    List<Map<String, dynamic>> maps;
    try {
      maps = await client.query('[$name]');
    } catch (e) {
      maps = [];
    }

    return List.generate(maps.length, (i) => FlashCard.fromMap(maps[i]));
  }

  List<FlashCard> initStack({String name, List<FlashCard> cards}) {
    List<FlashCard> list = List.from(cards);

    for (var i = 0; i < list.length; i++) {
      list[i].setKey = i;
      list[i].setTable = name;
      if (list[i].isSwipped == null) list[i].setSwipped = 0;
    }

    return list;
  }

  tableRatio({String name}) async {
    final list = await cardList(name: name);

    var sum = 0;
    list.forEach((e) => sum += e.isSwipped == 1 ? 1 : 0);

    return sum / list.length;
  }

  batchInsertCard({String name, List<FlashCard> cards}) async {
    final client = await db;
    final batch = client.batch();

    cards.forEach((e) => batch.insert('[$name]', e.toMap()));
    batch.commit(noResult: true);
  }

  batchResetCard({String name, int length}) async {
    final client = await db;
    final batch = client.batch();

    for (var i = 0; i < length; i++) {
      var sql = 'UPDATE [$name] SET isSwipped = 0 WHERE key = $i;';
      batch.rawQuery(sql);
    }

    batch.commit(noResult: true);
  }

  insertCard(FlashCard card, String name) async {
    final client = await db;

    await client.insert('[$name]', card.toMap());
  }

  updateCard(FlashCard card, String name) async {
    final client = await db;

    await client.update('[$name]', card.toMap(),
        where: 'key = ?', whereArgs: [card.key]);
  }

  deleteCard(FlashCard card, String name) async {
    Database client = await db;

    await client.delete('[$name]', where: 'key = ?', whereArgs: [card.key]);
  }
}
