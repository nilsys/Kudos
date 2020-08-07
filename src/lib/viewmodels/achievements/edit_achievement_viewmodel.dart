import 'dart:io';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/widgets.dart';
import 'package:kudosapp/helpers/image_loading.dart';
import 'package:kudosapp/models/access_level.dart';
import 'package:kudosapp/models/achievement_model.dart';
import 'package:kudosapp/models/achievement_owner_model.dart';
import 'package:kudosapp/models/messages/achievement_updated_message.dart';
import 'package:kudosapp/models/team_model.dart';
import 'package:kudosapp/models/user_model.dart';
import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/services/data_services/achievements_service.dart';
import 'package:kudosapp/services/dialog_service.dart';
import 'package:kudosapp/services/image_service.dart';
import 'package:kudosapp/services/navigation_service.dart';
import 'package:kudosapp/viewmodels/base_viewmodel.dart';

class EditAchievementViewModel extends BaseViewModel with ImageLoading {
  final _eventBus = locator<EventBus>();
  final _imageService = locator<ImageService>();
  final _dialogsService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();
  final _achievementsService = locator<AchievementsService>();

  final AchievementModel _initialAchievement;
  final AchievementModel _achievement = AchievementModel.empty();

  String get pageTitle =>
      _achievement.id == null ? localizer().create : localizer().edit;

  String get name => _achievement.name ?? "";

  set name(String value) {
    _achievement.name = value;
    notifyListeners();
  }

  String get description => _achievement.description ?? "";

  set description(String value) {
    _achievement.description = value;
    notifyListeners();
  }

  File get imageFile => _achievement.imageFile;

  String get imageUrl => _achievement.imageUrl;

  EditAchievementViewModel._(
      this._initialAchievement, TeamModel team, UserModel user) {
    if (_initialAchievement != null) {
      _achievement.updateWithModel(_initialAchievement);
    }
    if (team != null) {
      _achievement.owner = AchievementOwnerModel.fromTeam(team);
      _achievement.accessLevel = team.accessLevel;
    } else if (user != null) {
      _achievement.owner = AchievementOwnerModel.fromUser(user);
      _achievement.accessLevel = AccessLevel.private;
    }
  }

  factory EditAchievementViewModel.createTeamAchievement(TeamModel team) =>
      EditAchievementViewModel._(null, team, null);

  factory EditAchievementViewModel.createUserAchievement(UserModel user) =>
      EditAchievementViewModel._(null, null, user);

  factory EditAchievementViewModel.editAchievement(
          AchievementModel achievementModel) =>
      EditAchievementViewModel._(achievementModel, null, null);

  void pickFile(BuildContext context) async {
    if (isImageLoading) {
      return;
    }

    isImageLoading = true;
    _achievement.imageFile =
        await _imageService.pickImage(context) ?? _achievement.imageFile;
    isImageLoading = false;
  }

  Future<void> save(BuildContext context) async {
    AchievementModel updatedAchievement;
    String errorMessage;

    try {
      isBusy = true;

      if (name.isEmpty) {
        errorMessage = localizer().nameIsNullErrorMessage;
      } else if (description.isEmpty) {
        errorMessage = localizer().descriptionIsNullErrorMessage;
      } else {
        if (_achievement.id == null) {
          updatedAchievement =
              await _achievementsService.createAchievement(_achievement);
        } else {
          updatedAchievement =
              await _achievementsService.updateAchievement(_achievement);
        }
      }

      if (updatedAchievement != null) {
        _initialAchievement?.updateWithModel(updatedAchievement);
        _eventBus.fire(AchievementUpdatedMessage(updatedAchievement));
      }
    } on ArgumentError catch (exception) {
      errorMessage = exception.name == "file"
          ? localizer().fileIsNullErrorMessage
          : localizer().generalErrorMessage;
    } catch (exception) {
      errorMessage = localizer().generalErrorMessage;
    } finally {
      isBusy = false;
    }

    if (errorMessage != null) {
      _dialogsService.showOkDialog(context: context, content: errorMessage);
    } else {
      _navigationService.pop(context);
    }
  }
}
