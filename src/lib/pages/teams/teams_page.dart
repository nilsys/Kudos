import 'package:flutter/material.dart';
import 'package:kudosapp/kudos_theme.dart';
import 'package:kudosapp/models/groupped_list_item.dart';
import 'package:kudosapp/models/selection_action.dart';
import 'package:kudosapp/models/team_model.dart';
import 'package:kudosapp/pages/teams/edit_team_page.dart';
import 'package:kudosapp/pages/teams/manage_team_page.dart';
import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/viewmodels/teams/teams_viewmodel.dart';
import 'package:kudosapp/widgets/decorations/top_decorator.dart';
import 'package:kudosapp/widgets/gradient_app_bar.dart';
import 'package:kudosapp/widgets/groupped_list_widget.dart';
import 'package:kudosapp/widgets/simple_list_item.dart';
import 'package:provider/provider.dart';
import 'package:kudosapp/viewmodels/search_input_viewmodel.dart';
import 'package:kudosapp/widgets/search_input_widget.dart';

class TeamsPageRoute extends MaterialPageRoute<TeamModel> {
  TeamsPageRoute({
    @required SelectionAction selectionAction,
    @required bool showAddButton,
    Set<String> excludedTeamIds,
    Icon selectorIcon,
  }) : super(
          builder: (context) => TeamsPage(
            selectionAction: selectionAction,
            showAddButton: showAddButton,
            excludedTeamIds: excludedTeamIds,
            selectorIcon: selectorIcon,
          ),
          fullscreenDialog: true,
        );
}

class TeamsPage extends StatelessWidget {
  final Set<String> _excludedTeamIds;
  final SelectionAction _selectionAction;
  final Icon _selectorIcon;
  final bool _showAddButton;

  TeamsPage({
    @required SelectionAction selectionAction,
    @required bool showAddButton,
    Set<String> excludedTeamIds,
    Icon selectorIcon,
  })  : _excludedTeamIds = excludedTeamIds,
        _selectorIcon = selectorIcon ?? KudosTheme.defaultSelectorIcon,
        _selectionAction = selectionAction,
        _showAddButton = showAddButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: localizer().teams, elevation: 0),
      body: ChangeNotifierProvider<SearchInputViewModel>(
        create: (context) => SearchInputViewModel(),
        child:
            ChangeNotifierProxyProvider<SearchInputViewModel, TeamsViewModel>(
          create: (context) => TeamsViewModel(
            _selectionAction,
            excludedTeamIds: _excludedTeamIds,
          ),
          update: (context, searchViewModel, teamsViewModel) =>
              teamsViewModel..filterByName(searchViewModel.query),
          child: Column(
            children: <Widget>[
              _buildSearchBar(),
              Expanded(
                child: TopDecorator.buildLayoutWithDecorator(
                  Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: Consumer<TeamsViewModel>(
                          builder: (context, viewModel, child) {
                            return StreamBuilder<
                                List<GrouppedListItem<TeamModel>>>(
                              stream: viewModel.teamsStream,
                              builder: (BuildContext context,
                                  AsyncSnapshot<
                                          List<GrouppedListItem<TeamModel>>>
                                      snapshot) {
                                if (viewModel.isBusy || snapshot.data == null) {
                                  return _buildLoading();
                                }
                                if (snapshot.data?.isEmpty ?? true) {
                                  return _buildEmpty(
                                      viewModel.isAllTeamsListEmpty);
                                } else {
                                  return GrouppedListWidget(
                                    snapshot.data,
                                    (t) => _buildListItem(
                                      context,
                                      viewModel,
                                      t,
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                      Positioned.directional(
                        textDirection: TextDirection.ltr,
                        end: 16.0,
                        bottom: 32.0,
                        child: Visibility(
                          visible: _showAddButton,
                          child: FloatingActionButton(
                            onPressed: () {
                              Navigator.of(context).push(EditTeamRoute());
                            },
                            child: KudosTheme.addIcon,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(gradient: KudosTheme.mainGradient),
      child: SearchInputWidget(
        hintText: localizer().enterName,
        iconSize: 82,
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmpty(bool isAllTeamsListEmpty) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.7,
        child: Text(
            isAllTeamsListEmpty
                ? localizer().createYourOwnTeams
                : localizer().searchEmptyPlaceholder,
            textAlign: TextAlign.center,
            style: KudosTheme.sectionEmptyTextStyle),
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    TeamsViewModel viewModel,
    TeamModel team,
  ) {
    return SimpleListItem(
      title: team.name,
      onTap: () => viewModel.onTeamClicked(context, team),
      selectorIcon: _selectorIcon,
      imageShape: ImageShape.square(56, 4),
      imageUrl: team.imageUrl,
      useTextPlaceholder: true,
      addHeroAnimation: true,
    );
  }
}
