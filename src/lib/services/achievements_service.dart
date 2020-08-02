import 'dart:async';
import 'package:kudosapp/dto/achievement.dart';
import 'package:kudosapp/dto/achievement_holder.dart';
import 'package:kudosapp/dto/user_achievement.dart';
import 'package:kudosapp/models/achievement_model.dart';
import 'package:kudosapp/models/achievement_owner_model.dart';
import 'package:kudosapp/models/item_change.dart';
import 'package:kudosapp/models/item_change_type.dart';
import 'package:kudosapp/models/user_achievement_model.dart';
import 'package:kudosapp/models/user_model.dart';
import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/services/base_auth_service.dart';
import 'package:kudosapp/services/database/achievements_database_service.dart';
import 'package:kudosapp/services/database/database_service.dart';
import 'package:kudosapp/services/database/users_database_service.dart';
import 'package:kudosapp/services/image_service.dart';

class AchievementsService {
  final _imageService = locator<ImageService>();
  final _authService = locator<BaseAuthService>();
  final _databaseService = locator<DatabaseService>();
  final _usersDatabaseService = locator<UsersDatabaseService>();
  final _achievementsDatabaseService = locator<AchievementsDatabaseService>();

  Map<String, AchievementModel> _cachedAchievements;

  StreamSubscription _myAchievementsStreamSubscription;
  StreamSubscription _myTeamsAchievementsStreamSubscription;
  StreamSubscription _publicAchievementsStreamSubscription;

  void _onAchievementsStreamUpdated(
      Iterable<ItemChange<Achievement>> achievementChanges) {
    for (var achievementChange in achievementChanges) {
      var model = AchievementModel.fromAchievement(achievementChange.item);

      switch (achievementChange.changeType) {
        case ItemChangeType.remove:
          _cachedAchievements.remove(model);
          break;
        case ItemChangeType.add:
        case ItemChangeType.change:
        default:
          _cachedAchievements[model.id] = model;
          break;
      }
    }
  }

  void _updateAchievementsSubscription() {
    if (_myAchievementsStreamSubscription == null) {
      _myAchievementsStreamSubscription = _achievementsDatabaseService
          .getUserAchievementsStream(_authService.currentUser.id)
          .listen(_onAchievementsStreamUpdated);
    }

    if (_myTeamsAchievementsStreamSubscription == null) {
      _myTeamsAchievementsStreamSubscription = _achievementsDatabaseService
          .getUserTeamsAchievementsStream(_authService.currentUser.id)
          .listen(_onAchievementsStreamUpdated);
    }

    if (_publicAchievementsStreamSubscription == null) {
      _publicAchievementsStreamSubscription = _achievementsDatabaseService
          .getPublicAchievementsStream(_authService.currentUser.id)
          .listen(_onAchievementsStreamUpdated);
    }
  }

  Future<void> _cacheAchievements() async {
    var myAchievements = await _achievementsDatabaseService
        .getUserAchievements(_authService.currentUser.id);

    var myTeamsAchievements = await _achievementsDatabaseService
        .getUserTeamsAchievements(_authService.currentUser.id);

    var publicAchievements =
        await _achievementsDatabaseService.getPublicAchievements();

    var achievementsSet = {
      ...myAchievements,
      ...myTeamsAchievements,
      ...publicAchievements,
    };

    _cachedAchievements = Map.fromIterable(
      achievementsSet.map((a) => AchievementModel.fromAchievement(a)),
      key: (am) => am.id,
      value: (am) => am,
    );
  }

  Future<void> _loadAchievements() async {
    if (_cachedAchievements == null) {
      await _cacheAchievements();
    }

    _updateAchievementsSubscription();
  }

  Future<Map<String, AchievementModel>> getAchievementsMap() async {
    await _loadAchievements();
    return _cachedAchievements;
  }

  Future<Iterable<AchievementModel>> getAchievements() async {
    await _loadAchievements();
    return _cachedAchievements.values;
  }

  Future<AchievementModel> createAchievement(
    AchievementModel achievement,
  ) async {
    var imageData = await _imageService.uploadImage(achievement.imageFile);
    achievement.imageName = imageData.name;
    achievement.imageUrl = imageData.url;

    return _achievementsDatabaseService
        .createAchievement(Achievement.fromModel(achievement))
        .then((a) => AchievementModel.fromAchievement(a));
  }

  Future<AchievementModel> updateAchievement(
    AchievementModel achievementModel,
  ) async {
    bool updateImage = false;
    if (achievementModel.imageFile != null) {
      var imageData =
          await _imageService.uploadImage(achievementModel.imageFile);
      achievementModel.imageName = imageData.name;
      achievementModel.imageUrl = imageData.url;
      updateImage = true;
    }

    return _achievementsDatabaseService
        .updateAchievement(
          Achievement.fromModel(achievementModel),
          updateMetadata: true,
          updateImage: updateImage,
        )
        .then((a) => AchievementModel.fromAchievement(a));
  }

  Future<void> sendAchievement(
    UserModel recipient,
    UserAchievementModel userAcheivementModel,
  ) {
    final userAchievement = UserAchievement.fromModel(userAcheivementModel);

    return _databaseService.batchUpdate(
      [
        // add an achievement to user's achievements
        (batch) => _achievementsDatabaseService.createUserAchievement(
              recipient.id,
              userAchievement,
              batch: batch,
            ),
        // add a user to achievements
        (batch) => _achievementsDatabaseService.createAchievementHolder(
              userAcheivementModel.achievement.id,
              AchievementHolder.fromModel(recipient),
              batch: batch,
            ),
        // increment received_achievements_count
        (batch) => _usersDatabaseService.incrementRecievedAchievementsCount(
              recipient.id,
              batch: batch,
            ),
      ],
    );
  }

  Future<AchievementModel> transferAchievement(
    AchievementModel achievementModel,
    AchievementOwnerModel newOwner,
  ) async {
    var achievement = Achievement.fromModel(
      achievementModel,
      newOwner: newOwner,
    );

    return _achievementsDatabaseService
        .updateAchievement(achievement,
            updateAccessLevel: true, updateOwner: true)
        .then((a) => AchievementModel.fromAchievement(a));
  }

  Future<void> deleteAchievement(
    AchievementModel achievementModel, {
    int holdersCount,
  }) {
    if (holdersCount != null && holdersCount == 0) {
      return _achievementsDatabaseService
          .deleteAchievement(achievementModel.id);
    } else {
      var achievement = Achievement.fromModel(
        achievementModel,
        isActive: false,
      );
      return _achievementsDatabaseService.updateAchievement(
        achievement,
        updateIsActive: true,
      );
    }
  }

  Future<List<UserAchievementModel>> getReceivedAchievements(String userId) {
    return _achievementsDatabaseService.getReceivedAchievements(userId).then(
        (list) => list
            .map((ua) => UserAchievementModel.fromUserAchievement(ua))
            .toList());
  }

  Future<List<UserModel>> getAchievementHolders(String achivementId) async {
    return _achievementsDatabaseService
        .getAchievementHolders(achivementId)
        .then((list) => list
            .toSet()
            .map((h) => UserModel.fromUserReference(h.recipient))
            .toList());
  }

  Future<AchievementModel> getAchievement(String achivementId) async {
    if (_cachedAchievements != null &&
        _cachedAchievements.containsKey(achivementId)) {
      return _cachedAchievements[achivementId];
    }

    return _achievementsDatabaseService
        .getAchievement(achivementId)
        .then((a) => AchievementModel.fromAchievement(a));
  }

  Future<List<AchievementModel>> getTeamAchievements(String teamId) async {
    return _achievementsDatabaseService.getTeamAchievements(teamId).then(
        (list) =>
            list.map((a) => AchievementModel.fromAchievement(a)).toList());
  }

  Future<void> markCurrentUserAchievementAsViewed(
    AchievementModel achievement,
  ) {
    return _achievementsDatabaseService.markUserAchievementAsViewed(
      _authService.currentUser.id,
      achievement.id,
    );
  }

  void closeAchievementsSubscription() {
    _cachedAchievements = null;

    _myAchievementsStreamSubscription?.cancel();
    _myAchievementsStreamSubscription = null;

    _myTeamsAchievementsStreamSubscription?.cancel();
    _myTeamsAchievementsStreamSubscription = null;

    _publicAchievementsStreamSubscription?.cancel();
    _publicAchievementsStreamSubscription = null;
  }
}
