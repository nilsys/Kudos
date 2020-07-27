import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final _database = Firestore.instance;

  Future<void> batchUpdate(List<void Function(WriteBatch)> functions) {
    if (functions == null || functions.isEmpty) {
      return null;
    }
    var batch = _database.batch();

    for (var func in functions) {
      func.call(batch);
    }

    return batch.commit();
  }
}
