import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kudosapp/dto/team.dart';
import 'package:kudosapp/models/access_level.dart';
import 'package:kudosapp/models/item_change.dart';
import 'package:kudosapp/helpers/firestore_helpers.dart';

class TeamsDatabaseService {
  static const _teamsCollection = "teams";

  final _database = Firestore.instance;

  final _streamTransformer =
      StreamTransformer<QuerySnapshot, Iterable<ItemChange<Team>>>.fromHandlers(
    handleData: (querySnapshot, sink) {
      var teamsChanges = querySnapshot.documentChanges.map(
        (dc) => ItemChange<Team>(
          Team.fromJson(dc.document.data, dc.document.documentID),
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
        .where(field,
            isEqualTo: isEqualTo,
            isLessThan: isLessThan,
            arrayContains: arrayContains)
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
    ).getDocuments().then((value) =>
        value.documents.map((d) => Team.fromJson(d.data, d.documentID)));
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
        .document(teamId)
        .get()
        .then((value) => Team.fromJson(value.data, value.documentID));
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
        .then((value) => Team.fromJson(value.data, value.documentID));
  }

  Future<Team> updateTeam(
    Team team, {
    bool updateMetadata = false,
    bool updateImage = false,
    bool updateMembers = false,
    bool updateAccessLevel = false,
    bool updateIsActive = false,
    WriteBatch batch,
  }) async {
    final docRef = _database.collection(_teamsCollection).document(team.id);
    final map = team.toJson(
      addMetadata: updateMetadata,
      addImage: updateImage,
      addMembers: updateMembers,
      addAccessLevel: updateAccessLevel,
      addIsActive: updateIsActive,
    );
    if (batch == null) {
      await docRef
          .setData(map, merge: true)
          .then((value) => docRef.get())
          .then((value) => Team.fromJson(value.data, value.documentID));
    } else {
      batch.setData(docRef, map, merge: true);
    }
  }

  Future<void> deleteTeam(String teamId) {
    return _database.collection(_teamsCollection).document(teamId).delete();
  }
}
