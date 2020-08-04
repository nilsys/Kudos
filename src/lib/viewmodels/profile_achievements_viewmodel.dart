import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:kudosapp/models/achievement_model.dart';
import 'package:kudosapp/models/messages/achievement_sent_message.dart';
import 'package:kudosapp/models/messages/achievement_viewed_message.dart';
import 'package:kudosapp/models/user_achievement_collection.dart';
import 'package:kudosapp/models/user_achievement_model.dart';
import 'package:kudosapp/pages/achievements/achievement_details_page.dart';
import 'package:kudosapp/pages/profile/received_achievement_page.dart';
import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/services/base_auth_service.dart';
import 'package:kudosapp/services/achievements_service.dart';
import 'package:kudosapp/services/dialog_service.dart';
import 'package:kudosapp/viewmodels/base_viewmodel.dart';
import 'package:sortedmap/sortedmap.dart';

class ProfileAchievementsViewModel extends BaseViewModel {
  final _eventBus = locator<EventBus>();
  final _authService = locator<BaseAuthService>();
  final _dialogsService = locator<DialogService>();
  final _achievementsService = locator<AchievementsService>();

  final String _userId;
  final _receivedAchievements =
      SortedMap<String, UserAchievementCollection>(Ordering.byValue());
  Map<String, AchievementModel> _accessibleAchievementsMap;

  StreamSubscription<AchievementSentMessage> _achievementReceivedSubscription;
  StreamSubscription<AchievementViewedMessage> _achievementViewedSubscription;

  bool get hasAchievements => _receivedAchievements.isNotEmpty;
  bool get isMyProfile => _userId == _authService.currentUser.id;

  ProfileAchievementsViewModel(this._userId) {
    _initialize();
  }

  void _initialize() async {
    try {
      isBusy = true;

      _accessibleAchievementsMap =
          await _achievementsService.getAchievementsMap();

      final allUserAchievements =
          await _achievementsService.getReceivedAchievements(_userId);

      for (final userAchievement in allUserAchievements) {
        _addUserAchievementToMap(userAchievement);
      }

      _achievementReceivedSubscription?.cancel();
      _achievementReceivedSubscription =
          _eventBus.on<AchievementSentMessage>().listen(_onAchievementReceived);

      _achievementViewedSubscription?.cancel();
      _achievementViewedSubscription =
          _eventBus.on<AchievementViewedMessage>().listen(_onAchievementViewed);
    } finally {
      isBusy = false;
    }
  }

  List<UserAchievementCollection> getAchievements() =>
      _receivedAchievements.values.toList();

  void openAchievementDetails(
    BuildContext context,
    UserAchievementCollection achievementCollection,
  ) {
    var achievement =
        _accessibleAchievementsMap[achievementCollection.relatedAchievement.id];

    if (isMyProfile) {
      Navigator.of(context).push(
        ReceivedAchievementRoute(achievementCollection),
      );
    } else if (achievement == null || !achievement.canBeViewedByUser(_userId)) {
      _dialogsService.showOkDialog(
        context: context,
        title: localizer().accessDenied,
        content: localizer().privateAchievement,
      );
    } else {
      final achievement = achievementCollection.relatedAchievement;
      Navigator.of(context).push(AchievementDetailsRoute(achievement));
    }
  }

  void _addUserAchievementToMap(UserAchievementModel userAchievement) {
    final id = userAchievement.achievement.id;
    if (_receivedAchievements.containsKey(id)) {
      _receivedAchievements[id] =
          _receivedAchievements[id].addAchievement(userAchievement);
    } else {
      _receivedAchievements[id] =
          UserAchievementCollection.single(userAchievement);
    }
  }

  void _onAchievementReceived(AchievementSentMessage event) {
    if (event.recipient.id != _userId) {
      return;
    }

    _addUserAchievementToMap(event.userAchievement);
    notifyListeners();
  }

  void _onAchievementViewed(AchievementViewedMessage event) {
    final id = event.achievement.id;
    if (_receivedAchievements.containsKey(id)) {
      _receivedAchievements[id].hasNew = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _achievementReceivedSubscription.cancel();
    _achievementViewedSubscription.cancel();
    super.dispose();
  }
}
