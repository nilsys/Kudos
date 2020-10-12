import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final _database = FirebaseFirestore.instance;

  Future<void> batchUpdate(List<void Function(WriteBatch)> functions) async {
    if (functions == null || functions.isEmpty) {
      return;
    }
    var batch = _database.batch();

    for (var func in functions) {
      func.call(batch);
    }

    await batch.commit();
  }
}
