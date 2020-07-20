import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kudosapp/dto/user.dart';
import 'package:kudosapp/dto/user_registration.dart';
import 'package:kudosapp/models/user_model.dart';
import 'package:rxdart/rxdart.dart';

class UsersDatabaseService {
  static const _usersCollection = "users";
  static const _pushTokenCollection = "push_tokens";

  final _usersSubject = BehaviorSubject<List<UserModel>>();
  final _database = Firestore.instance;

  StreamSubscription _usersStreamSubscription;

  Stream<List<UserModel>> get usersStream => _usersSubject;

  void updateUsersListenerIfNeeded() {
    if (_usersStreamSubscription != null) {
      return;
    }

    _usersStreamSubscription = _database
        .collection(_usersCollection)
        .snapshots()
        .listen(_onUsersChange);
  }

  void stopListenUsers() {
    _usersStreamSubscription?.cancel();
    _usersStreamSubscription = null;
  }

  Future<List<UserModel>> getAllUsers() async {
    final qs = await _database.collection(_usersCollection).getDocuments();
    return _mapToUserModels(qs);
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

  void _onUsersChange(QuerySnapshot qs) {
    if (qs.documents.length == 0) {
      return;
    }

    final models = _mapToUserModels(qs);
    _usersSubject.add(models);
  }

  List<UserModel> _mapToUserModels(QuerySnapshot qs) {
    final models = qs.documents
        .map((x) => User.fromJson(x.data, x.documentID))
        .map((x) => UserModel.fromUser(x))
        .toList();
    models.sort((x, y) => x.name.compareTo(y.name));
    return models;
  }
}
