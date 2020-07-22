import 'package:flutter/material.dart';
import 'package:kudosapp/models/user_achievement_model.dart';
import 'package:kudosapp/models/user_model.dart';

@immutable
class AchievementSentMessage {
  final UserModel recipient;
  final UserAchievementModel userAchievement;

  AchievementSentMessage(this.recipient, this.userAchievement);
}
