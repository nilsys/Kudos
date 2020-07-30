import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/widgets.dart';
import 'package:kudosapp/models/achievement_model.dart';
import 'package:kudosapp/models/messages/achievement_deleted_message.dart';
import 'package:kudosapp/models/messages/achievement_transferred_message.dart';
import 'package:kudosapp/models/messages/achievement_updated_message.dart';
import 'package:kudosapp/models/messages/team_deleted_message.dart';
import 'package:kudosapp/models/team_member_model.dart';
import 'package:kudosapp/models/team_model.dart';
import 'package:kudosapp/pages/achievements/edit_achievement_page.dart';
import 'package:kudosapp/pages/team_member_picker_page.dart';
import 'package:kudosapp/pages/teams/edit_team_page.dart';
import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/services/base_auth_service.dart';
import 'package:kudosapp/services/achievements_service.dart';
import 'package:kudosapp/services/teams_service.dart';
import 'package:kudosapp/services/dialog_service.dart';
import 'package:kudosapp/viewmodels/base_viewmodel.dart';

class ManageTeamViewModel extends BaseViewModel {
  final _eventBus = locator<EventBus>();
  final _authService = locator<BaseAuthService>();
  final _teamsService = locator<TeamsService>();
  final _dialogService = locator<DialogService>();
  final _achievementsService = locator<AchievementsService>();

  final TeamModel _team;

  List<AchievementModel> achievements;

  StreamSubscription _achievementUpdatedSubscription;
  StreamSubscription _achievementDeletedSubscription;
  StreamSubscription _achievementTransferredSubscription;

  String get name => _team.name;
  String get description => _team.description;
  String get imageUrl => _team.imageUrl;
  Iterable<TeamMemberModel> get members => _team.members.values;

  bool get canEdit => _team.members == null
      ? false
      : _team.canBeModifiedByUser(_authService.currentUser.id);

  ManageTeamViewModel(this._team) {
    _initialize();
  }

  void _initialize() async {
    try {
      isBusy = true;

      final loadedTeam = await _teamsService.getTeam(_team.id);
      _team.updateWithModel(loadedTeam);

      achievements = await _achievementsService.getTeamAchievements(_team.id) ??
          new List<AchievementModel>();

      _achievementUpdatedSubscription?.cancel();
      _achievementUpdatedSubscription = _eventBus
          .on<AchievementUpdatedMessage>()
          .listen(_onAchievementUpdated);

      _achievementDeletedSubscription?.cancel();
      _achievementDeletedSubscription = _eventBus
          .on<AchievementDeletedMessage>()
          .listen(_onAchievementDeleted);

      _achievementTransferredSubscription?.cancel();
      _achievementTransferredSubscription = _eventBus
          .on<AchievementTransferredMessage>()
          .listen(_onAchievementTransferred);
    } finally {
      isBusy = false;
    }
  }

  void editMembers(BuildContext context) async {
    if (!canEdit) {
      return;
    }

    await Navigator.of(context).push(
      TeamMemberPickerRoute(
        _team,
        searchHint: localizer().searchMembers,
      ),
    );

    notifyListeners();
  }

  void editTeam(BuildContext context) async {
    await Navigator.of(context).push(EditTeamRoute(_team));
    notifyListeners();
  }

  void createAchievement(BuildContext context) {
    Navigator.of(context)
        .push(EditAchievementRoute.createTeamAchievement(_team));
  }

  void deleteTeam(BuildContext context) async {
    if (await _dialogService.showDeleteCancelDialog(
        context: context,
        title: localizer().warning,
        content: localizer().deleteTeamWarning)) {
      try {
        isBusy = true;

        await _teamsService.deleteTeam(_team, achievements);
        _eventBus.fire(TeamDeletedMessage(_team.id));
        _eventBus.fire(AchievementDeletedMessage.multiple(
            achievements.map((x) => x.id).toSet()));
        Navigator.popUntil(context, ModalRoute.withName('/'));
      } finally {
        isBusy = false;
      }
    }
  }

  void _onAchievementUpdated(AchievementUpdatedMessage event) {
    if (event.achievement.owner.id != _team.id) {
      return;
    }

    final index = achievements.indexWhere(
      (x) => x.id == event.achievement.id,
    );
    if (index != -1) {
      achievements.removeAt(index);
      achievements.insert(index, event.achievement);
    } else {
      achievements.add(event.achievement);
    }
    notifyListeners();
  }

  void _onAchievementDeleted(AchievementDeletedMessage event) {
    achievements.removeWhere((x) => event.ids.contains(x.id));
    notifyListeners();
  }

  void _onAchievementTransferred(AchievementTransferredMessage event) {
    if (event.achievements.first.owner.id != _team.id) {
      var achievementIds = event.achievements.map((a) => a.id).toSet();
      achievements.removeWhere((x) => achievementIds.contains(x.id));
    } else {
      var achievementIds = achievements.map((x) => x.id).toSet();
      for (var achievement in event.achievements) {
        if (!achievementIds.contains(achievement.id)) {
          achievements.add(achievement);
        }
      }
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _achievementUpdatedSubscription?.cancel();
    _achievementDeletedSubscription?.cancel();
    _achievementTransferredSubscription?.cancel();
    super.dispose();
  }
}
