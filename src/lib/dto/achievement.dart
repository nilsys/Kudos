import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:kudosapp/dto/team_member.dart';
import 'package:kudosapp/dto/team_reference.dart';
import 'package:kudosapp/dto/user_reference.dart';
import 'package:kudosapp/models/access_level.dart';
import 'package:kudosapp/models/achievement_model.dart';
import 'package:kudosapp/models/achievement_owner_model.dart';
import 'package:kudosapp/models/team_member_model.dart';
import 'package:kudosapp/models/team_model.dart';
import 'package:kudosapp/models/user_model.dart';

/// Achievements collection
@immutable
class Achievement extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String imageName;
  final TeamReference team;
  final UserReference user;
  final List<TeamMember> teamMembers;
  final int accessLevel;
  final bool isActive;

  Achievement._({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.imageUrl,
    @required this.team,
    @required this.user,
    @required this.imageName,
    @required this.teamMembers,
    @required this.accessLevel,
    @required this.isActive,
  });

  factory Achievement.fromJson(Map<String, dynamic> json, String id) {
    return json == null
        ? null
        : Achievement._(
            id: id ?? json["id"],
            name: json["name"],
            description: json["description"],
            imageUrl: json["image_url"],
            imageName: json["image_name"],
            team: TeamReference.fromJson(json["team"], null),
            user: UserReference.fromJson(json["user"], null),
            teamMembers: _getMembers(json["team_members"]),
            accessLevel: json["access_level"] ?? AccessLevel.public.index,
            isActive: json["is_active"],
          );
  }

  factory Achievement.fromModel(
    AchievementModel model, {
    bool isActive,
    AchievementOwnerModel newOwner,
    AccessLevel newAccessLevel,
  }) {
    UserModel user;
    TeamModel team;
    Iterable<TeamMemberModel> teamMembers;
    AccessLevel accessLevel;

    if (newOwner != null) {
      user = newOwner.user;
      team = newOwner.team;
      teamMembers = newOwner.team?.members?.values;
      accessLevel = newOwner.type == AchievementOwnerType.user
          ? AccessLevel.private
          : newOwner.team.accessLevel;
    } else {
      user = model.owner.user;
      team = model.owner.team;
      teamMembers = model.owner?.team?.members?.values;
      accessLevel = newAccessLevel?.index ?? model.accessLevel;
    }

    return Achievement._(
      id: model.id,
      name: model.name,
      description: model.description,
      imageUrl: model.imageUrl,
      imageName: model.imageName,
      team: team == null ? null : TeamReference.fromModel(team),
      user: user == null ? null : UserReference.fromModel(user),
      teamMembers:
          teamMembers?.map((tmm) => TeamMember.fromModel(tmm))?.toList(),
      accessLevel: accessLevel.index,
      isActive: isActive ?? true,
    );
  }

  Map<String, dynamic> toJson({
    bool addAll = false,
    bool addMetadata = false,
    bool addImage = false,
    bool addOwner = false,
    bool addAccessLevel = false,
    bool addIsActive = false,
  }) {
    final map = new Map<String, Object>();
    var visibleFor = List<String>();

    if (addAll || addMetadata) {
      map["name"] = this.name;
      map["description"] = this.description;
    }

    if (addAll || addImage) {
      map["image_url"] = this.imageUrl;
      map["image_name"] = this.imageName;
    }

    if (addAll || addOwner) {
      map["team"] = team == null ? null : team.toJson();
      map["user"] = user == null ? null : user.toJson();
      map["team_members"] =
          this.teamMembers?.map((tm) => tm.toJson())?.toList();
      visibleFor.addAll(this.teamMembers?.map((x) => x.id));
    }

    if (addAll || addAccessLevel) {
      map["access_level"] = this.accessLevel;
    }

    if (addAll || addIsActive) {
      map["is_active"] = this.isActive;
    }

    if (visibleFor.isNotEmpty) {
      visibleFor = visibleFor.toSet().toList();
      map["visible_for"] = visibleFor;
    }

    return map;
  }

  static List<TeamMember> _getMembers(List<dynamic> members) {
    if (members == null) {
      return List<TeamMember>();
    }

    var mapList = members.cast<Map<String, dynamic>>();
    return mapList.map((y) => TeamMember.fromJson(y, null)).toList();
  }

  @override
  List<Object> get props => [id];
}
