import 'package:event_bus/event_bus.dart';
import 'package:flutter/widgets.dart';
import 'package:kudosapp/models/achievement_model.dart';
import 'package:kudosapp/models/messages/achievement_viewed_message.dart';
import 'package:kudosapp/models/user_achievement_collection.dart';
import 'package:kudosapp/models/user_achievement_model.dart';
import 'package:kudosapp/pages/achievements/achievement_details_page.dart';
import 'package:kudosapp/pages/profile_page.dart';
import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/services/data_services/achievements_service.dart';
import 'package:kudosapp/services/navigation_service.dart';
import 'package:kudosapp/viewmodels/achievements/achievement_details_viewmodel.dart';
import 'package:kudosapp/viewmodels/base_viewmodel.dart';
import 'package:kudosapp/viewmodels/profile_viewmodel.dart';

class ReceivedAchievementViewModel extends BaseViewModel {
  final _eventBus = locator<EventBus>();
  final _navigationService = locator<NavigationService>();
  final _achievementsService = locator<AchievementsService>();

  final UserAchievementCollection achievementCollection;

  AchievementModel get relatedAchievement =>
      achievementCollection.relatedAchievement;

  ReceivedAchievementViewModel(this.achievementCollection) {
    _initialize();
  }

  void _initialize() async {
    await _markAsViewedIfNeeded();
  }

  Future<void> _markAsViewedIfNeeded() async {
    if (!achievementCollection.hasNew) {
      return;
    }
    final achievement = achievementCollection.relatedAchievement;
    await _achievementsService.markCurrentUserAchievementAsViewed(achievement);
    _eventBus.fire(AchievementViewedMessage(achievement));
  }

  void onUserAchievmentClicked(
    BuildContext context,
    UserAchievementModel userAchievementModel,
  ) {
    _navigationService.navigateToViewModel(
      context,
      ProfilePage(),
      ProfileViewModel(userAchievementModel.sender),
    );
  }

  void openAchievementDetails(BuildContext context) {
    _navigationService.navigateToViewModel(
      context,
      AchievementDetailsPage(),
      AchievementDetailsViewModel(relatedAchievement),
    );
  }
}
