import 'package:kudosapp/models/achievement.dart';
import 'package:kudosapp/models/user.dart';
import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/services/achievements_service.dart';
import 'package:kudosapp/viewmodels/base_viewmodel.dart';

class ProfileViewModel extends BaseViewModel {
  final AchievementsService _achievementsService = locator<AchievementsService>();
  final User user;

  List<Achievement> _achievements = [];

  ProfileViewModel(this.user);

  Future<List<Achievement>> get achievements async {
    if (_achievements.isEmpty) {
      _achievements = await _achievementsService.getUserAchievements(user.id);
    }
    return _achievements;
  }
}