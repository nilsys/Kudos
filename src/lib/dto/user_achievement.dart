import 'package:flutter/foundation.dart';
import 'package:kudosapp/dto/related_achievement.dart';
import 'package:kudosapp/dto/user_reference.dart';
import 'package:kudosapp/models/user_achievement_model.dart';

/// Users collection -> achievement_references subcollection
@immutable
class UserAchievement {
  final UserReference sender;
  final RelatedAchievement achievement;
  final String comment;
  final DateTime date;
  final bool viewed;

  UserAchievement._({
    @required this.sender,
    @required this.achievement,
    @required this.comment,
    @required this.date,
    @required this.viewed,
  });

  factory UserAchievement.fromModel(UserAchievementModel model) {
    return UserAchievement._(
      sender: UserReference.fromModel(model.sender),
      achievement: RelatedAchievement.fromModel(model.achievement),
      comment: model.comment,
      date: model.date,
      viewed: model.viewed,
    );
  }

  factory UserAchievement.fromJson(Map<String, dynamic> json, String id) {
    return json == null
        ? null
        : UserAchievement._(
            sender: UserReference.fromJson(json["sender"], null),
            achievement: RelatedAchievement.fromJson(json["achievement"], null),
            comment: json["comment"],
            date: json["date"].toDate(),
            viewed: json["viewed"] ?? true,
          );
  }

  Map<String, dynamic> toJson() {
    return {
      "sender": sender.toJson(),
      "achievement": achievement.toJson(),
      "comment": comment,
      "date": date,
      "viewed": viewed,
    };
  }
}
