import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kudosapp/dto/achievement.dart';
import 'package:kudosapp/dto/team.dart';
import 'package:kudosapp/models/access_level.dart';
import 'package:kudosapp/models/achievement_model.dart';
import 'package:kudosapp/models/team_member_model.dart';
import 'package:kudosapp/models/team_model.dart';
import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/services/achievements_service.dart';
import 'package:kudosapp/services/base_auth_service.dart';
import 'package:kudosapp/services/database/achievements_database_service.dart';
import 'package:kudosapp/services/database/database_service.dart';
import 'package:kudosapp/services/database/teams_database_service.dart';
import 'package:kudosapp/services/image_service.dart';

class TeamsService {
  final _imageService = locator<ImageService>();
  final _authService = locator<BaseAuthService>();
  final _databaseService = locator<DatabaseService>();
  final _teamsDatabaseService = locator<TeamsDatabaseService>();
  final _achievementsDatabaseService = locator<AchievementsDatabaseService>();
  final _achievementsService = locator<AchievementsService>();

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
    if (achievements != null && achievements.length == 0) {
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

  Future<List<TeamModel>> getTeams() async {
    var userTeams =
        await _teamsDatabaseService.getUserTeams(_authService.currentUser.id);
    var publicTeams = await _teamsDatabaseService.getPublicTeams();

    var teamsSet = {...userTeams, ...publicTeams};
    return teamsSet.map((t) => TeamModel.fromTeam(t)).toList();
  }

  Future<List<TeamModel>> getUserTeams(String userId) async {
    var userTeams = await _teamsDatabaseService.getUserTeams(userId);

    return userTeams.map((t) => TeamModel.fromTeam(t)).toList();
  }

  Future<TeamModel> getTeam(String teamId) {
    return _teamsDatabaseService
        .getTeam(teamId)
        .then((t) => TeamModel.fromTeam(t));
  }
}
