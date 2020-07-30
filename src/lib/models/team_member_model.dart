import 'package:kudosapp/dto/team_member.dart';
import 'package:kudosapp/models/user_access_level.dart';
import 'package:kudosapp/models/user_model.dart';

class TeamMemberModel {
  UserModel user;
  UserAccessLevel accessLevel;

  TeamMemberModel._({
    this.user,
    this.accessLevel,
  });

  factory TeamMemberModel.fromTeamMember(TeamMember teamMember) {
    return TeamMemberModel._(
      user: UserModel.fromTeamMember(teamMember),
      accessLevel: (UserAccessLevel.values[teamMember.accessLevel]),
    );
  }

  factory TeamMemberModel.fromUserModel(
      UserModel userModel, UserAccessLevel accessLevel) {
    return TeamMemberModel._(
      user: userModel,
      accessLevel: accessLevel,
    );
  }
}
