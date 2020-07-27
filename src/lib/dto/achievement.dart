import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:kudosapp/dto/team_member.dart';
import 'package:kudosapp/dto/team_reference.dart';
import 'package:kudosapp/dto/user_reference.dart';
import 'package:kudosapp/models/achievement_model.dart';
import 'package:kudosapp/models/achievement_owner_model.dart';

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
            isActive: json["is_active"],
          );
  }

  factory Achievement.fromModel(
    AchievementModel model, {
    bool isActive,
    AchievementOwnerModel newOwner,
  }) {
    UserReference userReference;
    TeamReference teamReference;
    List<TeamMember> teamMembers;

    if (newOwner != null) {
      userReference =
          newOwner.user != null ? UserReference.fromModel(newOwner.user) : null;
      teamReference =
          newOwner.team != null ? TeamReference.fromModel(newOwner.team) : null;
      teamMembers = newOwner.team?.members?.values
          ?.map((tmm) => TeamMember.fromModel(tmm))
          ?.toList();
    } else {
      userReference = model.owner.user != null
          ? UserReference.fromModel(model.owner.user)
          : null;
      teamReference = model.owner.team != null
          ? TeamReference.fromModel(model.owner.team)
          : null;
      teamMembers = model.owner?.team?.members?.values
          ?.map((tmm) => TeamMember.fromModel(tmm))
          ?.toList();
    }

    return Achievement._(
      id: model.id,
      name: model.name,
      description: model.description,
      imageUrl: model.imageUrl,
      imageName: model.imageName,
      team: teamReference,
      user: userReference,
      teamMembers: teamMembers,
      isActive: isActive ?? true,
    );
  }

  Map<String, dynamic> toJson({
    bool addAll = false,
    bool addMetadata = false,
    bool addImage = false,
    bool addOwner = false,
    bool addIsActive = false,
  }) {
    final map = new Map<String, Object>();

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
    }

    if (addAll || addIsActive) {
      map["is_active"] = this.isActive;
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
