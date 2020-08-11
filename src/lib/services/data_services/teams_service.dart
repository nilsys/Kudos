import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kudosapp/dto/achievement.dart';
import 'package:kudosapp/dto/team.dart';
import 'package:kudosapp/models/access_level.dart';
import 'package:kudosapp/models/achievement_model.dart';
import 'package:kudosapp/models/item_change.dart';
import 'package:kudosapp/models/team_member_model.dart';
import 'package:kudosapp/models/team_model.dart';
import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/services/data_services/achievements_service.dart';
import 'package:kudosapp/services/base_auth_service.dart';
import 'package:kudosapp/services/data_services/cached_data_service.dart';
import 'package:kudosapp/services/database/achievements_database_service.dart';
import 'package:kudosapp/services/database/database_service.dart';
import 'package:kudosapp/services/database/teams_database_service.dart';
import 'package:kudosapp/services/image_service.dart';

class TeamsService extends CachedDataService<Team, TeamModel> {
  static const InputStreamsCount = 2;

  final _imageService = locator<ImageService>();
  final _authService = locator<BaseAuthService>();
  final _databaseService = locator<DatabaseService>();
  final _teamsDatabaseService = locator<TeamsDatabaseService>();
  final _achievementsDatabaseService = locator<AchievementsDatabaseService>();
  final _achievementsService = locator<AchievementsService>();

  TeamsService() : super(InputStreamsCount);

  Future<Iterable<TeamModel>> getTeams() async {
    await loadData();
    return cachedData.values;
  }

  Future<Map<String, TeamModel>> getTeamsMap() async {
    await loadData();
    return cachedData;
  }

  Future<List<TeamModel>> getUserTeams(String userId) async {
    var userTeams = await _teamsDatabaseService.getUserTeams(userId);
    return userTeams.map((t) => TeamModel.fromTeam(t)).toList();
  }

  Future<TeamModel> getTeam(String teamId) async {
    await loadData();
    if (cachedData.containsKey(teamId)) {
      return cachedData[teamId];
    }

    return _teamsDatabaseService
        .getTeam(teamId)
        .then((t) => TeamModel.fromTeam(t));
  }

  Future<TeamModel> createTeam(TeamModel teamModel) async {
    if (teamModel.imageFile != null) {
      var imageData = await _imageService.uploadImage(teamModel.imageFile);
      teamModel.imageUrl = imageData.url;
      teamModel.imageName = imageData.name;
    }

    var team = Team.fromModel(teamModel);

    return _teamsDatabaseService
        .createTeam(team)
        .then((t) => TeamModel.fromTeam(t));
  }

  Future<TeamModel> editTeam(TeamModel teamModel) async {
    bool updateImage = false;
    if (teamModel.imageFile != null) {
      var imageData = await _imageService.uploadImage(teamModel.imageFile);
      teamModel.imageUrl = imageData.url;
      teamModel.imageName = imageData.name;
      updateImage = true;
    }

    return _teamsDatabaseService
        .updateTeam(
          Team.fromModel(teamModel),
          updateMetadata: true,
          updateImage: updateImage,
        )
        .then((t) => TeamModel.fromTeam(t));
  }

  Future<void> setTeamAccessLevel(
    TeamModel teamModel,
    AccessLevel accessLevel,
  ) async {
    var funcs = new List<void Function(WriteBatch)>();

    funcs.add(
      (batch) => _teamsDatabaseService.updateTeam(
        Team.fromModel(
          teamModel,
          newAccessLevel: accessLevel,
        ),
        updateAccessLevel: true,
        batch: batch,
      ),
    );

    var teamAchievements =
        await _achievementsService.getTeamAchievements(teamModel.id);

    for (var achievement in teamAchievements) {
      funcs.add(
        (batch) => _achievementsDatabaseService.updateAchievement(
          Achievement.fromModel(achievement, newAccessLevel: accessLevel),
          updateAccessLevel: true,
          batch: batch,
        ),
      );
    }

    return _databaseService.batchUpdate(funcs);
  }

  Future<void> updateTeamMembers(
    TeamModel teamModel,
    List<TeamMemberModel> newMembers,
  ) async {
    var funcs = new List<void Function(WriteBatch)>();

    funcs.add(
      (batch) => _teamsDatabaseService.updateTeam(
        Team.fromModel(
          teamModel,
          newMembers: newMembers,
        ),
        updateMembers: true,
        batch: batch,
      ),
    );

    var teamAchievements =
        await _achievementsService.getTeamAchievements(teamModel.id);

    for (var achievement in teamAchievements) {
      funcs.add(
        (batch) => _achievementsDatabaseService.updateAchievement(
          Achievement.fromModel(
            achievement,
            newMembers: newMembers,
          ),
          updateTeamMembers: true,
          batch: batch,
        ),
      );
    }

    return _databaseService.batchUpdate(funcs);
  }

  Future<void> deleteTeam(
      TeamModel teamModel, List<AchievementModel> achievements) async {
    if (achievements != null && achievements.isEmpty) {
      return _teamsDatabaseService.deleteTeam(teamModel.id);
    }

    var team = Team.fromModel(teamModel, isActive: false);

    _databaseService.batchUpdate(
      [
        (batch) => _teamsDatabaseService.updateTeam(team,
            updateIsActive: true, batch: batch),
        (batch) {
          if (achievements != null) {
            for (var achievementModel in achievements) {
              var achievement =
                  Achievement.fromModel(achievementModel, isActive: false);
              _achievementsDatabaseService.updateAchievement(achievement,
                  updateIsActive: true, batch: batch);
            }
          }
        },
      ],
    );
  }

  Future<bool> isTeamNameUnique(String name, String teamId) async {
    var teamIds = await _teamsDatabaseService.findTeamIdsByName(name);
    return teamIds.length == 0 || (teamId != null && teamIds.contains(teamId));
  }

  @override
  TeamModel convert(Team item) => TeamModel.fromTeam(item);

  @override
  Future<Iterable<Team>> getDataFromInputStream(int index) {
    switch (index) {
      // My teams
      case 0:
        return _teamsDatabaseService.getUserTeams(_authService.currentUser.id);
      // Accessible teams (public and protected)
      case 1:
      default:
        return _teamsDatabaseService.getAccessibleTeams();
    }
  }

  @override
  Stream<Iterable<ItemChange<Team>>> getInputStream(int index) {
    switch (index) {
      // My teams
      case 0:
        return _teamsDatabaseService
            .getUserTeamsStream(_authService.currentUser.id);
      // Accessible teams (public and protected)
      case 1:
      default:
        return _teamsDatabaseService.getAccessibleTeamsStream();
    }
  }

  @override
  String getItemId(TeamModel item) => item.id;
}
