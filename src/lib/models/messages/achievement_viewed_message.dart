import 'package:flutter/material.dart';
import 'package:kudosapp/models/achievement_model.dart';

@immutable
class AchievementViewedMessage {
  final AchievementModel achievement;

  AchievementViewedMessage(this.achievement);
}
