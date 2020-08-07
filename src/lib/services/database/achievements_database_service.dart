import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kudosapp/dto/achievement.dart';
import 'package:kudosapp/dto/achievement_holder.dart';
import 'package:kudosapp/dto/user_achievement.dart';
import 'package:kudosapp/models/access_level.dart';
import 'package:kudosapp/models/item_change.dart';
import 'package:kudosapp/helpers/firestore_helpers.dart';

class AchievementsDatabaseService {
  static const _usersCollection = "users";
  static const _achievementsCollection = "achievements";
  static const _achievementReferencesCollection = "achievement_references";
  static const _achievementHoldersCollection = "holders";

  final _database = Firestore.instance;

  final _streamTransformer = StreamTransformer<QuerySnapshot,
      Iterable<ItemChange<Achievement>>>.fromHandlers(
    handleData: (querySnapshot, sink) {
      var achievementsChanges = querySnapshot.documentChanges.map(
        (dc) => ItemChange<Achievement>(
          Achievement.fromJson(dc.document.data, dc.document.documentID),
          dc.type.toItemChangeType(),
        ),
      );

      sink.add(achievementsChanges);
    },
  );

  Query _getAchievementsQuery(
    String field, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic arrayContains,
  }) {
    return _database
        .collection(_achievementsCollection)
        .where(field,
            isEqualTo: isEqualTo,
            isLessThan: isLessThan,
            arrayContains: arrayContains)
        .where("is_active", isEqualTo: true);
  }

  Stream<Iterable<ItemChange<Achievement>>> _getAchievementsStream(
    String field, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic arrayContains,
  }) {
    return _getAchievementsQuery(
      field,
      isEqualTo: isEqualTo,
      isLessThan: isLessThan,
      arrayContains: arrayContains,
    ).snapshots().transform(_streamTransformer);
  }

  Future<Iterable<Achievement>> _getAchievements(
    String field, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic arrayContains,
  }) {
    return _getAchievementsQuery(
      field,
      isEqualTo: isEqualTo,
      isLessThan: isLessThan,
      arrayContains: arrayContains,
    ).getDocuments().then((value) =>
        value.documents.map((d) => Achievement.fromJson(d.data, d.documentID)));
  }

  Stream<Iterable<ItemChange<Achievement>>> getUserAchievementsStream(
      String userId) {
    return _getAchievementsStream("user.id", isEqualTo: userId);
  }

  Stream<Iterable<ItemChange<Achievement>>> getUserTeamsAchievementsStream(
      String userId) {
    return _getAchievementsStream("visible_for", arrayContains: userId);
  }

  Stream<Iterable<ItemChange<Achievement>>> getAccessibleAchievementsStream() {
    return _getAchievementsStream(
      "access_level",
      isLessThan: AccessLevel.private.index,
    );
  }

  Future<Iterable<Achievement>> getUserTeamsAchievements(String userId) {
    return _getAchievements("visible_for", arrayContains: userId);
  }

  Future<Iterable<Achievement>> getAccessibleAchievements() {
    return _getAchievements("access_level",
        isLessThan: AccessLevel.private.index);
  }

  Future<Iterable<Achievement>> getTeamAchievements(String teamId) {
    return _getAchievements("team.id", isEqualTo: teamId);
  }

  Future<Iterable<Achievement>> getUserAchievements(String userId) {
    return _getAchievements("user.id", isEqualTo: userId);
  }

  Future<Achievement> getAchievement(String achivementId) {
    return _database
        .collection(_achievementsCollection)
        .document(achivementId)
        .get()
        .then((value) => Achievement.fromJson(value.data, value.documentID));
  }

  Future<Iterable<AchievementHolder>> getAchievementHolders(
      String achievementId) {
    return _database
        .collection(
            "$_achievementsCollection/$achievementId/$_achievementHoldersCollection")
        .getDocuments()
        .then((value) =>
            value.documents.map((d) => AchievementHolder.fromJson(d.data)));
  }

  Future<void> createAchievementHolder(
      String achievementId, AchievementHolder achievementHolder,
      {WriteBatch batch}) async {
    final docRef = _database
        .collection("$_achievementsCollection/$achievementId/holders")
        .document();

    final holderMap = achievementHolder.toJson();

    if (batch == null) {
      await docRef.setData(holderMap);
    } else {
      batch.setData(docRef, holderMap);
    }
  }

  Future<void> createUserAchievement(
      String recipientId, UserAchievement userAchievement,
      {WriteBatch batch}) async {
    final docRef = _database
        .collection(
            "$_usersCollection/$recipientId/$_achievementReferencesCollection")
        .document();

    if (batch == null) {
      await docRef.setData(userAchievement.toJson());
    } else {
      batch.setData(docRef, userAchievement.toJson());
    }
  }

  Future<Achievement> createAchievement(Achievement achievement) {
    return _database
        .collection(_achievementsCollection)
        .add(achievement.toJson(addAll: true))
        .then((value) => value.get())
        .then((value) => Achievement.fromJson(value.data, value.documentID));
  }

  Future<Iterable<UserAchievement>> getReceivedAchievements(
    String userId,
  ) {
    return _database
        .collection(
            "$_usersCollection/$userId/$_achievementReferencesCollection")
        .getDocuments()
        .then((value) => value.documents
            .map((d) => UserAchievement.fromJson(d.data, d.documentID)));
  }

  Future<Achievement> updateAchievement(
    Achievement achievement, {
    bool updateMetadata = false,
    bool updateImage = false,
    bool updateOwner = false,
    bool updateTeamMembers = false,
    bool updateAccessLevel = false,
    bool updateIsActive = false,
    WriteBatch batch,
  }) {
    final docRef =
        _database.collection(_achievementsCollection).document(achievement.id);
    final map = achievement.toJson(
      addMetadata: updateMetadata,
      addImage: updateImage,
      addOwner: updateOwner,
      addTeamMembers: updateTeamMembers,
      addAccessLevel: updateAccessLevel,
      addIsActive: updateIsActive,
    );
    if (batch == null) {
      return docRef
          .setData(map, merge: true)
          .then((value) => docRef.get())
          .then((value) => Achievement.fromJson(value.data, value.documentID));
    } else {
      batch.setData(docRef, map, merge: true);
      return Future<Achievement>.value(null);
    }
  }

  Future<void> markUserAchievementAsViewed(
    String userId,
    String achievementId,
  ) {
    final path = "$_usersCollection/$userId/$_achievementReferencesCollection";
    return _database
        .collection(path)
        .where("achievement.id", isEqualTo: achievementId)
        .getDocuments()
        .then(
          (snapshots) => snapshots.documents.forEach((document) {
            document.reference.updateData({"viewed": true});
          }),
        );
  }

  Future<void> deleteAchievement(String achievementId) {
    return _database
        .collection(_achievementsCollection)
        .document(achievementId)
        .delete();
  }
}
