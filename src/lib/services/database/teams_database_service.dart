import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kudosapp/dto/team.dart';
import 'package:kudosapp/models/access_level.dart';
import 'package:kudosapp/services/cache/item_change.dart';
import 'package:kudosapp/helpers/firestore_helpers.dart';

class TeamsDatabaseService {
  static const _teamsCollection = "teams";

  final _database = FirebaseFirestore.instance;

  final _streamTransformer =
      StreamTransformer<QuerySnapshot, Iterable<ItemChange<Team>>>.fromHandlers(
    handleData: (querySnapshot, sink) {
      var teamsChanges = querySnapshot.docChanges.map(
        (dc) => ItemChange<Team>(
          Team.fromJson(dc.doc.data(), dc.doc.id),
          dc.type.toItemChangeType(),
        ),
      );

      sink.add(teamsChanges);
    },
  );

  Query _getTeamsQuery(
    String field, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic arrayContains,
  }) {
    return _database
        .collection(_teamsCollection)
        .where(
          field,
          isEqualTo: isEqualTo,
          isLessThan: isLessThan,
          arrayContains: arrayContains,
        )
        .where("is_active", isEqualTo: true);
  }

  Stream<Iterable<ItemChange<Team>>> _getTeamsStream(
    String field, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic arrayContains,
  }) {
    return _getTeamsQuery(
      field,
      isEqualTo: isEqualTo,
      isLessThan: isLessThan,
      arrayContains: arrayContains,
    ).snapshots().transform(_streamTransformer);
  }

  Future<Iterable<Team>> _getTeams(
    String field, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic arrayContains,
  }) {
    return _getTeamsQuery(
      field,
      isEqualTo: isEqualTo,
      isLessThan: isLessThan,
      arrayContains: arrayContains,
    )
        .get()
        .then((value) => value.docs.map((d) => Team.fromJson(d.data(), d.id)));
  }

  Stream<Iterable<ItemChange<Team>>> getUserTeamsStream(String userId) {
    return _getTeamsStream("visible_for", arrayContains: userId);
  }

  Stream<Iterable<ItemChange<Team>>> getAccessibleTeamsStream() {
    return _getTeamsStream("access_level",
        isLessThan: AccessLevel.private.index);
  }

  Future<Iterable<Team>> getUserTeams(String userId) {
    return _getTeams("visible_for", arrayContains: userId);
  }

  Future<Iterable<Team>> getAccessibleTeams() {
    return _getTeams("access_level", isLessThan: AccessLevel.private.index);
  }

  Future<Team> getTeam(String teamId) {
    return _database
        .collection(_teamsCollection)
        .doc(teamId)
        .get()
        .then((value) => Team.fromJson(value.data(), value.id));
  }

  Future<Iterable<String>> findTeamIdsByName(String name) {
    return _getTeams("name", isEqualTo: name)
        .then((teams) => teams.map((d) => d.id));
  }

  Future<Team> createTeam(Team team) {
    return _database
        .collection(_teamsCollection)
        .add(team.toJson(addAll: true))
        .then((value) => value.get())
        .then((value) => Team.fromJson(value.data(), value.id));
  }

  Future<Team> updateTeam(
    Team team, {
    bool updateMetadata = false,
    bool updateImage = false,
    bool updateMembers = false,
  }) {
    final docRef = _database.collection(_teamsCollection).doc(team.id);
    final map = team.toJson(
      addMetadata: updateMetadata,
      addImage: updateImage,
      addMembers: updateMembers,
    );

    return docRef
        .set(map, SetOptions(merge: true))
        .then((value) => docRef.get())
        .then((value) => Team.fromJson(value.data(), value.id));
  }

  Future<void> deleteTeam(String teamId) {
    return _database.collection(_teamsCollection).doc(teamId).delete();
  }
}
