import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stackr/model/studystack.dart';

import 'flashcard.dart';

class DBHelper {
  static final DBHelper _instance = new DBHelper.internal();

  factory DBHelper() => _instance;
  static Database _study;
  static Database _feat;

  DBHelper.internal();

  Future<Database> get study async => _study ?? await studyDB();
  Future<Database> get feat async => _feat ?? await featureDB();

  getClient(table) => table.contains('Featured') ? feat : study;

  studyDB() async {
    var path = join(await getDatabasesPath(), 'stack.db');
    return await openDatabase(path, version: 1);
  }

  featureDB() async {
    var path = join(await getDatabasesPath(), 'feature.db');
    return await openDatabase(path, version: 1);
  }

  createStack({String name}) async {
    var client = await getClient(name);

    await client.execute("""
      CREATE TABLE [$name](
        key INT PRIMARY KEY,
        theme TEXT,
        isSwipped INT,
        question TEXT,
        answer TEXT
      )""");
  }

  dropStack({String name}) async {
    var client = await getClient(name);

    await client.execute('DROP TABLE IF EXISTS [$name]');
  }

  Future<int> tableLength({String table}) async {
    Database client = await getClient(table);

    var count = await client.rawQuery('SELECT COUNT (*) from [$table]');

    return Sqflite.firstIntValue(count);
  }

  Future<bool> tableExist({String table}) async {
    Database client = await getClient(table);

    var sql = """SELECT * FROM sqlite_master 
                  WHERE TYPE = 'table'
                  AND name = '$table'""";
    var exist = await client.rawQuery(sql);

    return exist != null && exist.isNotEmpty;
  }

  Future<List<StudyStack>> tableList(
      Future<Database> dbClient, String filter) async {
    var client = await dbClient;
    var query = (await client.rawQuery("""
                SELECT * FROM sqlite_master
                  WHERE type = 'table' 
                  AND name != 'android_metadata' 
                  AND name != 'sqlite_sequence';
                """)).reversed.toList();

    var list = filter.isNotEmpty
        ? query.expand(
            (e) => [
              if ((e['name'] as String)
                  .toLowerCase()
                  .replaceAll('_', ' ')
                  .contains(filter))
                e
            ],
          )
        : query;

    return Future.wait(list.map((e) async {
      String table = e['name'] as String;
      int cards = await tableLength(table: table);
      return StudyStack(table, cards);
    }));
  }

  Future<List<FlashCard>> cardList({String table}) async {
    Database client = await getClient(table);
    List<Map<String, dynamic>> maps;

    try {
      maps = await client.query('[$table]');
    } catch (e) {
      maps = [];
    }

    return List.generate(maps.length, (i) => FlashCard.fromMap(maps[i]));
  }

  updateFeatured({String table, List<FlashCard> card}) async {
    final client = await getClient(table);

    var query = await client.query("sqlite_master",
        where: "name LIKE ?", whereArgs: ['%Featured%']);

    if (query.isNotEmpty) {
      var name = query.map((row) => row['name'] as String);
      dropStack(name: name.toList()[0]);
    }

    createStack(name: table);
    batchInsertCard(table: table, cards: card);
  }

  initStack({String table, List<FlashCard> cards}) {
    List<FlashCard> list = List.from(cards);

    for (var i = 0; i < list.length; i++) {
      list[i].setKey = i;
      list[i].setTable = table;
      if (list[i].isSwipped == null) list[i].setSwipped = 0;
    }

    return list;
  }

  tableRatio({String table}) async {
    final list = await cardList(table: table);

    var sum = 0;
    list.forEach((e) => sum += e.isSwipped == 1 ? 1 : 0);

    return sum / list.length;
  }

  batchInsertCard({String table, List<FlashCard> cards}) async {
    final client = await getClient(table);
    final batch = client.batch();

    cards.forEach((e) => batch.insert('[$table]', e.toMap()));

    batch.commit(noResult: true);
  }

  batchResetCard({String table, int length}) async {
    final client = await getClient(table);
    final batch = client.batch();

    for (var i = 0; i < length; i++) {
      batch.rawQuery('UPDATE [$table] SET isSwipped = 0 WHERE key = $i;');
    }

    batch.commit(noResult: true);
  }

  insertCard(FlashCard card, String table) async {
    final client = await getClient(table);

    await client.insert('[$table]', card.toMap());
  }

  updateCard(FlashCard card, String table) async {
    final client = await getClient(table);

    await client.update('[$table]', card.toMap(),
        where: 'key = ?', whereArgs: [card.key]);
  }

  deleteCard(FlashCard card, String table) async {
    Database client = await getClient(table);

    await client.delete('[$table]', where: 'key = ?', whereArgs: [card.key]);
  }
}
