import 'dart:io' as io;
import 'dart:convert' show utf8;
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:stackr/model/flashcard.dart';
import 'package:stackr/model/user_inherited.dart';

class FBHelper {
  final BuildContext context;

  const FBHelper(this.context) : assert(context != null);

  static FBHelper of(BuildContext context) => FBHelper(context);

  Future<bool> downloadList(List<String> list, storage.Reference ref) async {
    try {
      for (var i = 0; i < list.length; i++) {
        await downloadFile(ref.child('Medicine/' + list[i]));
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> downloadFile(storage.Reference ref) async {
    final item = ref.name;
    final tempFile = _createTempFile(item);

    await ref.writeToFile(tempFile);

    final input = tempFile.openRead();

    await _saveToSQL(input, item);

    await tempFile.delete();
  }

  io.File _createTempFile(String name) {
    final io.Directory systemTempDir = io.Directory.systemTemp;
    return io.File('${systemTempDir.path}/temp-$name');
  }

  Future<void> _saveToSQL(Stream<List<int>> file, String name) async {
    final table = await file
        .transform(utf8.decoder)
        .transform(CsvToListConverter())
        .toList();

    name = name.substring(0, name.length - 4);

    final list = _buildStack(table);

    final data = UserData.of(this.context);
    await data.dbClient.createStack(name: name);
    data.dbClient.batchInsertCard(name: name, cards: list);
    data.generateTableList();

    data.refresh();
  }

  List<FlashCard> _buildStack(List<List<dynamic>> table) {
    final list = List<FlashCard>();
    for (var i = 0; i < table.length; i++) {
      var r = table[i];
      var card = FlashCard(
          key: i, theme: r[1], question: r[2], answer: r[3], isSwipped: 0);
      list.add(card);
    }
    return list;
  }
}
