import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kudosapp/models/user.dart';

@immutable
class TeamMember {
  final String id;
  final String name;

  factory TeamMember.fromUser(User user) {
    return TeamMember._(user.id, user.name);
  }

  factory TeamMember.fromDocument(DocumentSnapshot x) {
    return TeamMember._(x.documentID, x.data["name"]);
  }

  TeamMember._(this.id, this.name);

  Map<String, dynamic> toMap() {
    return {
      "name": name,
    };
  }
}
