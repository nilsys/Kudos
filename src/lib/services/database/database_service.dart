import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final _database = Firestore.instance;

  Future<void> batchUpdate(
    void Function(WriteBatch) f1,
    void Function(WriteBatch) f2, {
    void Function(WriteBatch) f3,
  }) {
    var batch = _database.batch();

    f1.call(batch);
    f2.call(batch);
    f3?.call(batch);

    return batch.commit();
  }
}
