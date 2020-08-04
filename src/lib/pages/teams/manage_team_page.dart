import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kudosapp/helpers/access_level_utils.dart';
import 'package:kudosapp/kudos_theme.dart';
import 'package:kudosapp/models/achievement_model.dart';
import 'package:kudosapp/models/team_member_model.dart';
import 'package:kudosapp/models/team_model.dart';
import 'package:kudosapp/models/user_access_level.dart';
import 'package:kudosapp/pages/achievements/achievement_details_page.dart';
import 'package:kudosapp/pages/profile_page.dart';
import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/viewmodels/teams/manage_team_viewmodel.dart';
import 'package:kudosapp/widgets/achievements/achievement_list_item_widget.dart';
import 'package:kudosapp/widgets/common/rounded_image_widget.dart';
import 'package:kudosapp/widgets/gradient_app_bar.dart';
import 'package:kudosapp/widgets/section_header_widget.dart';
import 'package:provider/provider.dart';

class ManageTeamRoute extends MaterialPageRoute {
  ManageTeamRoute(TeamModel teamModel)
      : super(
          builder: (context) {
            return ChangeNotifierProvider<ManageTeamViewModel>(
              create: (context) {
                return ManageTeamViewModel(teamModel);
              },
              child: _ManageTeamPage(),
            );
          },
        );
}

class _ManageTeamPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ManageTeamPageState();
}

class _ManageTeamPageState extends State<_ManageTeamPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ManageTeamViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: GradientAppBar(
            title: viewModel.name,
            actions: viewModel.canEdit
                ? <Widget>[
                    IconButton(
                      icon: KudosTheme.editIcon,
                      onPressed: () => viewModel.editTeam(context),
                    ),
                    IconButton(
                      icon: KudosTheme.deleteIcon,
                      onPressed: () {
                        viewModel.deleteTeam(context);
                      },
                    ),
                  ]
                : null,
          ),
          body: _buildBody(viewModel),
          floatingActionButton: viewModel.canEdit
              ? FloatingActionButton(
                  onPressed: () => viewModel.createAchievement(context),
                  child: KudosTheme.addIcon,
                )
              : null,
        );
      },
    );
  }

  Widget _buildBody(ManageTeamViewModel viewModel) {
    var children = <Widget>[
      viewModel.imageUrl == null
          ? Container()
          : RoundedImageWidget.square(
              imageUrl: viewModel.imageUrl,
              size: 112.0,
              borderRadius: 8,
              title: viewModel.name,
              addHeroAnimation: true,
            ),
      SizedBox(height: 24),
    ];

    if (viewModel.isBusy) {
      children.add(Center(
        child: CircularProgressIndicator(),
      ));
    } else {
      children.add(Visibility(
        visible: viewModel.description.isNotEmpty,
        child: Text(
          viewModel.description,
          style: KudosTheme.descriptionTextStyle,
        ),
      ));
      children.add(Visibility(
        visible: viewModel.description.isNotEmpty,
        child: SizedBox(height: 10.0),
      ));
      children.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              AccessLevelUtils.getIcon(viewModel.accessLevel),
              color: KudosTheme.mainGradientEndColor,
              size: 20.0,
            ),
            SizedBox(
              width: 6.0,
            ),
            Text(
              AccessLevelUtils.getString(viewModel.accessLevel),
              style: KudosTheme.descriptionTextStyle,
            ),
          ],
        ),
      );
      children.add(SizedBox(height: 24.0));
      children.add(
        Padding(
          padding: EdgeInsets.only(left: 16.0, right: 8.0),
          child: _buildMembersList(
            localizer().members,
            viewModel.members,
            viewModel.canEdit,
            () => viewModel.editMembers(context),
          ),
        ),
      );
      children.add(SizedBox(height: 24.0));
      children.add(
        Padding(
          padding: EdgeInsets.only(left: 16.0, right: 8.0),
          child: SectionHeaderWidget(localizer().achievements),
        ),
      );
      children.add(SizedBox(height: 10.0));
      children.add(
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final data = viewModel.achievements[index];
            return AchievementListItemWidget(data, _achievementTapped, null);
          },
          itemCount: viewModel.achievements?.length ?? 0,
        ),
      );
    }

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMembersList(String title, Iterable<TeamMemberModel> members,
      bool canEdit, void Function() editUsers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: KudosTheme.sectionTitleTextStyle,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: KudosTheme.editIcon,
                  color: KudosTheme.accentColor,
                  disabledColor: Colors.transparent,
                  onPressed: canEdit ? editUsers : null,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.0),
        _TeamMembersListWidget(members),
      ],
    );
  }

  void _achievementTapped(AchievementModel achievement) {
    Navigator.of(context).push(AchievementDetailsRoute(achievement));
  }
}

class _TeamMembersListWidget extends StatelessWidget {
  final Iterable<TeamMemberModel> _teamMembers;

  _TeamMembersListWidget(this._teamMembers);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Wrap(
          children: _buildListItems(context, _teamMembers),
          runSpacing: 10,
          spacing: 10),
    );
  }

  List<Widget> _buildListItems(
      BuildContext context, Iterable<TeamMemberModel> items) {
    return items == null
        ? new List<Widget>()
        : items.map((user) => _buildUserAvatar(context, user)).toList();
  }

  Widget _buildUserAvatar(BuildContext context, TeamMemberModel teamMember) {
    return Tooltip(
      message: teamMember.user.name,
      child: GestureDetector(
        child: SizedBox(
          width: 65,
          height: 65,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: RoundedImageWidget.circular(
                  size: 60,
                  imageUrl: teamMember.user.imageUrl,
                  title: teamMember.user.name,
                ),
              ),
              Visibility(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: SvgPicture.asset("assets/icons/crown.svg",
                      width: 24, height: 24),
                ),
                visible: teamMember.accessLevel == UserAccessLevel.admin,
              ),
            ],
          ),
        ),
        onTap: () => Navigator.of(context).push(ProfileRoute(teamMember.user)),
      ),
      decoration: KudosTheme.tooltipDecoration,
      textStyle: KudosTheme.tooltipTextStyle,
      verticalOffset: 33,
    );
  }
}
