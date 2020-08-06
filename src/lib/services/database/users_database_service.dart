import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kudosapp/dto/user.dart';
import 'package:kudosapp/dto/user_registration.dart';
import 'package:kudosapp/models/item_change.dart';
import 'package:kudosapp/helpers/firestore_helpers.dart';

class UsersDatabaseService {
  static const _usersCollection = "users";
  static const _pushTokenCollection = "push_tokens";

  final _database = Firestore.instance;

  final _streamTransformer =
      StreamTransformer<QuerySnapshot, Iterable<ItemChange<User>>>.fromHandlers(
    handleData: (querySnapshot, sink) {
      var usersChanges = querySnapshot.documentChanges.map(
        (dc) => ItemChange<User>(
          User.fromJson(dc.document.data, dc.document.documentID),
          dc.type.toItemChangeType(),
        ),
      );

      sink.add(usersChanges);
    },
  );

  Query _getUsersQuery() {
    return _database.collection(_usersCollection);
  }

  Stream<Iterable<ItemChange<User>>> getUsersStream() {
    return _getUsersQuery().snapshots().transform(_streamTransformer);
  }

  Future<Iterable<User>> getUsers() async {
    return _getUsersQuery().getDocuments().then((value) =>
        value.documents.map((d) => User.fromJson(d.data, d.documentID)));
  }

  Future<void> registerUser(
    String userId,
    UserRegistration userRegistration,
    String pushToken,
  ) async {
    await _database
        .collection(_usersCollection)
        .document(userId)
        .setData(userRegistration.toJson(), merge: true);

    if (pushToken != null) {
      await _database
          .collection(_usersCollection)
          .document(userId)
          .collection(_pushTokenCollection)
          .add({"token": pushToken});
    }
  }

  Future<void> incrementRecievedAchievementsCount(String userId,
      {WriteBatch batch}) async {
    var docRef = _database.collection(_usersCollection).document(userId);

    if (batch != null) {
      batch.updateData(
          docRef, {"received_achievements_count": FieldValue.increment(1)});
    } else {
      return docRef
          .updateData({"received_achievements_count": FieldValue.increment(1)});
    }
  }
}
