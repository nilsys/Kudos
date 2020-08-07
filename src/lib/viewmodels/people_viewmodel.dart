import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kudosapp/models/selection_action.dart';
import 'package:kudosapp/models/user_model.dart';
import 'package:kudosapp/pages/profile_page.dart';
import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/services/data_services/users_service.dart';
import 'package:kudosapp/services/navigation_service.dart';
import 'package:kudosapp/viewmodels/base_viewmodel.dart';
import 'package:kudosapp/viewmodels/profile_viewmodel.dart';

class PeopleViewModel extends BaseViewModel {
  final _peopleService = locator<UsersService>();
  final _navigationService = locator<NavigationService>();

  final Set<String> _excludedUserIds;
  final SelectionAction _selectionAction;

  StreamController<String> _streamController;
  Stream<List<UserModel>> _peopleStream;
  List<UserModel> _peopleList;

  Stream<List<UserModel>> get peopleStream => _peopleStream;

  PeopleViewModel(this._selectionAction, {Set<String> excludedUserIds})
      : _excludedUserIds = excludedUserIds {
    _initFilter();
    _initialize();
  }

  void filterByName(String query) {
    _streamController.add(query);
  }

  void onItemClicked(BuildContext context, UserModel user) async {
    switch (_selectionAction) {
      case SelectionAction.OpenDetails:
        await _navigationService.navigateToViewModel(
            context, ProfilePage(), ProfileViewModel(user));
        updatePeopleList();
        break;
      case SelectionAction.Pop:
        _navigationService.pop(context, user);
        break;
    }
  }

  void _initialize() async {
    await _loadPeopleList();
    filterByName("");
  }

  void _initFilter() {
    _streamController = StreamController<String>();
    _peopleStream = _streamController.stream.transform(
      StreamTransformer<String, List<UserModel>>.fromHandlers(
        handleData: (query, sink) {
          if (_peopleList == null || _peopleList.isEmpty) {
            return;
          }

          sink.add(_filterByName(query));
        },
      ),
    );
  }

  Future<void> _loadPeopleList() async {
    try {
      isBusy = true;
      var loadedUsers = await _peopleService.getAllUsers();

      if (_excludedUserIds == null || _excludedUserIds.isEmpty) {
        _peopleList = loadedUsers.toList();
      } else {
        _peopleList = List.from(loadedUsers);
        _peopleList.removeWhere((x) => _excludedUserIds.contains(x.id));
      }
    } finally {
      isBusy = false;
    }
  }

  void updatePeopleList() async {
    if (_excludedUserIds == null || _excludedUserIds.isEmpty) {
      notifyListeners();
    } else {
      try {
        isBusy = true;
        var loadedList = await _peopleService.getAllUsers();

        _peopleList.clear();
        _peopleList.addAll(loadedList);
        _peopleList.removeWhere((x) => _excludedUserIds.contains(x.id));
      } finally {
        isBusy = false;
      }
    }
  }

  List<UserModel> _filterByName(String query) {
    if (query.isEmpty) {
      return _peopleList;
    }

    final filteredPeople = _peopleList
        .where((x) => x.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return filteredPeople;
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }
}
