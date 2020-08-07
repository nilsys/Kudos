import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:kudosapp/dto/team_member.dart';
import 'package:kudosapp/models/access_level.dart';
import 'package:kudosapp/models/team_member_model.dart';
import 'package:kudosapp/models/team_model.dart';

/// Teams collection
@immutable
class Team extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final String imageName;
  final String description;
  final List<TeamMember> members;
  final int accessLevel;
  final bool isActive;

  Team._({
    this.id,
    this.name,
    this.imageUrl,
    this.imageName,
    this.description,
    this.members,
    this.accessLevel,
    this.isActive,
  });

  factory Team.fromModel(
    TeamModel model, {
    bool isActive,
    AccessLevel newAccessLevel,
    List<TeamMemberModel> newMembers,
  }) {
    return Team._(
      id: model.id,
      name: model.name,
      imageUrl: model.imageUrl,
      imageName: model.imageName,
      description: model.description,
      members: newMembers?.map((tmm) => TeamMember.fromModel(tmm))?.toList() ??
          model.members?.values
              ?.map((tmm) => TeamMember.fromModel(tmm))
              ?.toList(),
      accessLevel: newAccessLevel?.index ?? model.accessLevel.index,
      isActive: isActive ?? model.isActive,
    );
  }

  factory Team.fromJson(
    Map<String, dynamic> json,
    String id,
  ) {
    return json == null
        ? null
        : Team._(
            id: id ?? json["id"],
            name: json["name"],
            imageUrl: json["image_url"],
            imageName: json["image_name"],
            description: json["description"],
            members: _getMembers(json["members"]),
            accessLevel: json["access_level"] ?? AccessLevel.public.index,
            isActive: json["is_active"],
          );
  }

  Map<String, dynamic> toJson({
    bool addAll = false,
    bool addMetadata = false,
    bool addImage = false,
    bool addMembers = false,
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

    if (addAll || addMembers) {
      map["members"] = this.members?.map((tm) => tm.toJson())?.toList();
      if (this.members != null) {
        visibleFor.addAll(this.members.map((x) => x.id));
      }
      visibleFor = visibleFor.toSet().toList();
      map["visible_for"] = visibleFor.isNotEmpty ? visibleFor : null;
    }

    if (addAll || addAccessLevel) {
      map["access_level"] = this.accessLevel;
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
