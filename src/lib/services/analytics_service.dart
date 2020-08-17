import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';

class AnalyticsService {
  static final _analytics = FirebaseAnalytics();
  final NavigatorObserver observer =
      FirebaseAnalyticsObserver(analytics: _analytics);

  void setCurrentScreen(String screenName) {
    _analytics.setCurrentScreen(screenName: screenName);
  }

  void logAppOpened() => _analytics.logAppOpen();
  void logSignIn() => _analytics.logLogin();
  void logSignOut() => _analytics.logEvent(name: "Logout");

  void logAchievementSent() => _analytics.logEvent(name: "Achievement sent");
  void logAchievementCreated() =>
      _analytics.logEvent(name: "Achievement created");
  void logAchievementUpdated() =>
      _analytics.logEvent(name: "Achievement updated");
  void logAchievementTransferred() =>
      _analytics.logEvent(name: "Achievement transferred");
  void logAchievementDeleted() =>
      _analytics.logEvent(name: "Achievement deleted");

  void logTeamCreated() => _analytics.logEvent(name: "Team created");
  void logTeamUpdated() => _analytics.logEvent(name: "Team updated");
  void logTeamMembersUpdated() =>
      _analytics.logEvent(name: "Team members updated");
  void logTeamDeleted() => _analytics.logEvent(name: "Team deleted");

  void logImageSizeTooLarge() =>
      _analytics.logEvent(name: "Image size is too large");
}
