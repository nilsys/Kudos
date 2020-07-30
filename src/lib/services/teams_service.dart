import 'package:kudosapp/dto/achievement.dart';
import 'package:kudosapp/dto/team.dart';
import 'package:kudosapp/models/achievement_model.dart';
import 'package:kudosapp/models/team_member_model.dart';
import 'package:kudosapp/models/team_model.dart';
import 'package:kudosapp/service_locator.dart';
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
          updateAccessLevel: true,
          updateImage: updateImage,
        )
        .then((t) => TeamModel.fromTeam(t));
  }

  Future<TeamModel> updateTeamMembers(
      TeamModel teamModel, List<TeamMemberModel> newMembers) {
    var team = Team.fromModel(teamModel, newMembers: newMembers);

    return _teamsDatabaseService
        .updateTeam(team, updateMembers: true)
        .then((t) => TeamModel.fromTeam(t));
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

  Future<List<TeamModel>> getTeams([String userId]) async {
    userId = userId ?? _authService.currentUser.id;

    var userTeams = await _teamsDatabaseService.getUserTeams(userId);
    var publicTeams = await _teamsDatabaseService.getPublicTeams();

    var teamsSet = {...userTeams, ...publicTeams};
    return teamsSet.map((t) => TeamModel.fromTeam(t)).toList();
  }

  Future<TeamModel> getTeam(String teamId) {
    return _teamsDatabaseService
        .getTeam(teamId)
        .then((t) => TeamModel.fromTeam(t));
  }

  Future<Iterable<String>> findTeamIdsByName(String name) {
    return _teamsDatabaseService.findTeamIdsByName(name);
  }
}
