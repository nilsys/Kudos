import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:kudosapp/models/messages/team_deleted_message.dart';
import 'package:kudosapp/models/messages/team_updated_message.dart';
import 'package:kudosapp/models/team_model.dart';
import 'package:kudosapp/models/user_model.dart';
import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/services/base_auth_service.dart';
import 'package:kudosapp/services/teams_service.dart';
import 'package:kudosapp/viewmodels/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sorted_list/sorted_list.dart';

class TeamsViewModel extends BaseViewModel {
  final _eventBus = locator<EventBus>();
  final _teamsService = locator<TeamsService>();
  static final _authService = locator<BaseAuthService>();

  final _teamsList = new SortedList<TeamModel>(_sortFunc);
  final Set<String> _excludedTeamIds;

  StreamController<String> _streamController;
  Stream<List<TeamModel>> _teamsStream;

  StreamSubscription _teamUpdatedSubscription;
  StreamSubscription _teamDeletedSubscription;

  Stream<List<TeamModel>> get teamsStream => _teamsStream;
  UserModel get currentUser => _authService.currentUser;
  bool get isAllTeamsListEmpty => _teamsList.isEmpty;

  TeamsViewModel({Set<String> excludedTeamIds})
      : _excludedTeamIds = excludedTeamIds {
    _initFilter();
    _initialize();
  }

  static int _sortFunc(TeamModel x, TeamModel y) {
    var userId = _authService.currentUser.id;

    int xAccess = x.isTeamAdmin(userId) ? 2 : x.isTeamMember(userId) ? 1 : 0;
    int yAccess = y.isTeamAdmin(userId) ? 2 : y.isTeamMember(userId) ? 1 : 0;

    if (xAccess == yAccess) {
      return x.name.toLowerCase().compareTo(y.name.toLowerCase());
    } else {
      return yAccess.compareTo(xAccess);
    }
  }

  void _initialize() async {
    isBusy = true;

    await _loadTeamsList();

    _teamUpdatedSubscription?.cancel();
    _teamUpdatedSubscription =
        _eventBus.on<TeamUpdatedMessage>().listen(_onTeamUpdated);

    _teamDeletedSubscription?.cancel();
    _teamDeletedSubscription =
        _eventBus.on<TeamDeletedMessage>().listen(_onTeamDeleted);

    isBusy = false;
  }

  void filterByName(String query) => _streamController.add(query);

  Future<TeamModel> loadTeam(String id) {
    return _teamsService.getTeam(id);
  }

  void _initFilter() {
    _streamController = StreamController<String>();

    _teamsStream = _streamController.stream
        .debounceTime(Duration(milliseconds: 100))
        .distinct()
        .transform(StreamTransformer<String, List<TeamModel>>.fromHandlers(
          handleData: (query, sink) => sink.add(
              query.isEmpty ? _teamsList : _filterByName(_teamsList, query)),
        ));
  }

  List<TeamModel> _filterByName(List<TeamModel> teams, String query) {
    final filteredTeams = teams
        .where((x) => x.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return filteredTeams;
  }

  Future<void> _loadTeamsList() async {
    var teams = await _teamsService.getTeams();
    _teamsList.clear();
    if (_excludedTeamIds != null) {
      var localTeams =
          teams.where((team) => !_excludedTeamIds.contains(team.id));
      _teamsList.addAll(localTeams);
    } else {
      _teamsList.addAll(teams);
    }
  }

  void _onTeamUpdated(TeamUpdatedMessage event) {
    _initialize();
  }

  void _onTeamDeleted(TeamDeletedMessage event) {
    _teamsList.removeWhere((x) => x.id == event.teamId);
    notifyListeners();
  }

  @override
  void dispose() {
    _teamUpdatedSubscription?.cancel();
    _teamDeletedSubscription?.cancel();
    super.dispose();
  }
}
