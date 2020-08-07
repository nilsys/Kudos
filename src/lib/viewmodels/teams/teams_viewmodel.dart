import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:kudosapp/models/groupped_list_item.dart';
import 'package:kudosapp/models/messages/team_deleted_message.dart';
import 'package:kudosapp/models/messages/team_updated_message.dart';
import 'package:kudosapp/models/selection_action.dart';
import 'package:kudosapp/models/team_model.dart';
import 'package:kudosapp/pages/teams/edit_team_page.dart';
import 'package:kudosapp/pages/teams/manage_team_page.dart';
import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/services/base_auth_service.dart';
import 'package:kudosapp/services/data_services/teams_service.dart';
import 'package:kudosapp/services/navigation_service.dart';
import 'package:kudosapp/viewmodels/base_viewmodel.dart';
import 'package:kudosapp/viewmodels/teams/edit_team_viewmodel.dart';
import 'package:kudosapp/viewmodels/teams/manage_team_viewmodel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sorted_list/sorted_list.dart';

class TeamsViewModel extends BaseViewModel {
  final _eventBus = locator<EventBus>();
  final _teamsService = locator<TeamsService>();
  final _authService = locator<BaseAuthService>();
  final _navigationService = locator<NavigationService>();

  final _selectionAction;
  final _teamsList = new SortedList<GrouppedListItem<TeamModel>>(_sortFunc);
  final Set<String> _excludedTeamIds;

  StreamController<String> _streamController;
  Stream<List<GrouppedListItem<TeamModel>>> _teamsStream;

  StreamSubscription _teamUpdatedSubscription;
  StreamSubscription _teamDeletedSubscription;

  Stream<List<GrouppedListItem<TeamModel>>> get teamsStream => _teamsStream;

  bool get isAllTeamsListEmpty => _teamsList.isEmpty;

  TeamsViewModel(this._selectionAction, {Set<String> excludedTeamIds})
      : _excludedTeamIds = excludedTeamIds {
    _initFilter();
    _initialize();
  }

  static int _sortFunc(
      GrouppedListItem<TeamModel> x, GrouppedListItem<TeamModel> y) {
    if (x.sortIndex == y.sortIndex) {
      return x.item.name.toLowerCase().compareTo(y.item.name.toLowerCase());
    } else {
      return y.sortIndex.compareTo(x.sortIndex);
    }
  }

  void _initialize() async {
    try {
      isBusy = true;

      await _loadTeamsList();

      _teamUpdatedSubscription?.cancel();
      _teamUpdatedSubscription =
          _eventBus.on<TeamUpdatedMessage>().listen(_onTeamUpdated);

      _teamDeletedSubscription?.cancel();
      _teamDeletedSubscription =
          _eventBus.on<TeamDeletedMessage>().listen(_onTeamDeleted);
    } finally {
      isBusy = false;
    }
  }

  void filterByName(String query) => _streamController.add(query);

  Future<TeamModel> loadTeam(String id) {
    return _teamsService.getTeam(id);
  }

  void createTeam(BuildContext context) {
    _navigationService.navigateToViewModel(
      context,
      EditTeamPage(),
      EditTeamViewModel(),
    );
  }

  void onTeamClicked(BuildContext context, TeamModel team) {
    switch (_selectionAction) {
      case SelectionAction.OpenDetails:
        _navigationService.navigateToViewModel(
            context, ManageTeamPage(), ManageTeamViewModel(team));
        break;
      case SelectionAction.Pop:
        _navigationService.pop(context, team);
        break;
    }
  }

  void _initFilter() {
    _streamController = StreamController<String>();

    _teamsStream = _streamController.stream
        .debounceTime(Duration(milliseconds: 100))
        .distinct()
        .transform(StreamTransformer<String,
            List<GrouppedListItem<TeamModel>>>.fromHandlers(
          handleData: (query, sink) => sink.add(_filterByName(query)),
        ));
  }

  List<GrouppedListItem> _filterByName(String query) {
    if (query.isEmpty) {
      return _teamsList;
    } else {
      final filteredTeams = _teamsList
          .where((x) => x.item.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      return filteredTeams;
    }
  }

  Future<void> _loadTeamsList() async {
    var teams = await _teamsService.getTeams();
    _teamsList.clear();
    if (_excludedTeamIds != null) {
      var localTeams = teams
          .where((team) => !_excludedTeamIds.contains(team.id))
          .map((tm) => _createGrouppedItemFromTeam(tm));
      _teamsList.addAll(localTeams);
    } else {
      _teamsList.addAll(teams.map((tm) => _createGrouppedItemFromTeam(tm)));
    }
  }

  GrouppedListItem<TeamModel> _createGrouppedItemFromTeam(TeamModel team) {
    int sortIndex = team.isTeamAdmin(_authService.currentUser.id) ||
            team.isTeamMember(_authService.currentUser.id)
        ? 1
        : 0;

    final myTeamsText = localizer().myTeams;
    final otherTeamsText = localizer().otherTeams;
    String groupName = sortIndex > 0 ? myTeamsText : otherTeamsText;

    return GrouppedListItem<TeamModel>(groupName, sortIndex, team);
  }

  void _onTeamUpdated(TeamUpdatedMessage event) {
    _initialize();
  }

  void _onTeamDeleted(TeamDeletedMessage event) {
    _teamsList.removeWhere((x) => x.item.id == event.teamId);
    notifyListeners();
  }

  @override
  void dispose() {
    _teamUpdatedSubscription?.cancel();
    _teamDeletedSubscription?.cancel();
    super.dispose();
  }
}
