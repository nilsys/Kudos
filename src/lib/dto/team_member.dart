import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:kudosapp/models/team_member_model.dart';

/// Teams collection -> team_members array
@immutable
class TeamMember extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final int accessLevel;

  TeamMember._({
    this.id,
    this.name,
    this.imageUrl,
    this.accessLevel,
  });

  factory TeamMember.fromModel(TeamMemberModel model) {
    return TeamMember._(
      id: model.user.id,
      name: model.user.name,
      imageUrl: model.user.imageUrl,
      accessLevel: model.accessLevel.index,
    );
  }

  factory TeamMember.fromJson(Map<String, dynamic> json, String id) {
    return json == null
        ? null
        : TeamMember._(
            id: id ?? json["id"],
            name: json["name"],
            imageUrl: json["image_url"],
            accessLevel: json["access_level"],
          );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "image_url": imageUrl,
      "access_level": accessLevel,
    };
  }

  @override
  List<Object> get props => [id];
}
