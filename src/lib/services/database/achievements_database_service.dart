import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kudosapp/dto/achievement.dart';
import 'package:kudosapp/dto/achievement_holder.dart';
import 'package:kudosapp/dto/user_achievement.dart';
import 'package:kudosapp/helpers/firestore_helpers.dart';
import 'package:kudosapp/models/access_level.dart';
import 'package:kudosapp/services/cache/item_change.dart';

class AchievementsDatabaseService {
  static const _usersCollection = "users";
  static const _achievementsCollection = "achievements";
  static const _achievementReferencesCollection = "achievement_references";
  static const _achievementHoldersCollection = "holders";

  final _database = FirebaseFirestore.instance;

  final _streamTransformer = StreamTransformer<QuerySnapshot,
      Iterable<ItemChange<Achievement>>>.fromHandlers(
    handleData: (querySnapshot, sink) {
      var achievementsChanges = querySnapshot.docChanges.map(
        (dc) => ItemChange<Achievement>(
          Achievement.fromJson(dc.doc.data(), dc.doc.id),
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
        .where(
          field,
          isEqualTo: isEqualTo,
          isLessThan: isLessThan,
          arrayContains: arrayContains,
        )
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
    ).get().then(
        (value) => value.docs.map((d) => Achievement.fromJson(d.data(), d.id)));
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

  Future<Achievement> getAchievement(String achievementId) {
    return _database
        .collection(_achievementsCollection)
        .doc(achievementId)
        .get()
        .then((value) => Achievement.fromJson(value.data(), value.id));
  }

  Future<Iterable<AchievementHolder>> getAchievementHolders(
      String achievementId) {
    return _database
        .collection(
            "$_achievementsCollection/$achievementId/$_achievementHoldersCollection")
        .get()
        .then((value) =>
            value.docs.map((d) => AchievementHolder.fromJson(d.data())));
  }

  Future<void> createAchievementHolder(
      String achievementId, AchievementHolder achievementHolder,
      {WriteBatch batch}) async {
    final docRef = _database
        .collection("$_achievementsCollection/$achievementId/holders")
        .doc();

    final holderMap = achievementHolder.toJson();

    if (batch == null) {
      await docRef.set(holderMap);
    } else {
      batch.set(docRef, holderMap);
    }
  }

  Future<void> createUserAchievement(
      String recipientId, UserAchievement userAchievement,
      {WriteBatch batch}) async {
    final docRef = _database
        .collection(
            "$_usersCollection/$recipientId/$_achievementReferencesCollection")
        .doc();

    if (batch == null) {
      await docRef.set(userAchievement.toJson());
    } else {
      batch.set(docRef, userAchievement.toJson());
    }
  }

  Future<Achievement> createAchievement(Achievement achievement) {
    return _database
        .collection(_achievementsCollection)
        .add(achievement.toJson(addAll: true))
        .then((value) => value.get())
        .then((value) => Achievement.fromJson(value.data(), value.id));
  }

  Future<Iterable<UserAchievement>> getReceivedAchievements(
    String userId,
  ) {
    return _database
        .collection(
            "$_usersCollection/$userId/$_achievementReferencesCollection")
        .get()
        .then((value) =>
            value.docs.map((d) => UserAchievement.fromJson(d.data(), d.id)));
  }

  Future<Achievement> updateAchievement(
    Achievement achievement, {
    bool updateMetadata = false,
    bool updateImage = false,
    bool updateOwner = false,
    bool updateIsActive = false,
  }) {
    final docRef =
        _database.collection(_achievementsCollection).doc(achievement.id);
    final map = achievement.toJson(
      addMetadata: updateMetadata,
      addImage: updateImage,
      addOwner: updateOwner,
      addIsActive: updateIsActive,
    );
    return docRef
        .set(map, SetOptions(merge: true))
        .then((value) => docRef.get())
        .then((value) => Achievement.fromJson(value.data(), value.id));
  }

  Future<void> markUserAchievementAsViewed(
    String userId,
    String achievementId,
  ) {
    final path = "$_usersCollection/$userId/$_achievementReferencesCollection";
    return _database
        .collection(path)
        .where("achievement.id", isEqualTo: achievementId)
        .get()
        .then(
          (snapshots) => snapshots.docs.forEach((document) {
            document.reference.update({"viewed": true});
          }),
        );
  }

  Future<void> deleteAchievement(String achievementId) {
    return _database
        .collection(_achievementsCollection)
        .doc(achievementId)
        .delete();
  }
}
