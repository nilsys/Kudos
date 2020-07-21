import 'dart:async';

import 'package:kudosapp/models/user_model.dart';
import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/services/people_service.dart';
import 'package:kudosapp/viewmodels/base_viewmodel.dart';

class PeopleViewModel extends BaseViewModel {
  final _peopleService = locator<PeopleService>();
  final _peopleList = List<UserModel>();
  final Set<String> _excludedUserIds;

  StreamController<String> _streamController;
  Stream<List<UserModel>> _peopleStream;

  Stream<List<UserModel>> get peopleStream => _peopleStream;

  PeopleViewModel({Set<String> excludedUserIds})
      : _excludedUserIds = excludedUserIds {
    _initFilter();
    _initialize();
  }

  void filterByName(String query) {
    _streamController.add(query);
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
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
          if (_peopleList.length == 0) {
            return;
          }

          sink.add(
              query.isEmpty ? _peopleList : _filterByName(_peopleList, query));
        },
      ),
    );
  }

  Future<void> _loadPeopleList() async {
    if (_peopleList.isEmpty) {
      List<UserModel> people = [];

      people = await _peopleService.getAllUsers();

      _peopleList.addAll(people);

      if (_excludedUserIds != null) {
        _peopleList.removeWhere((x) => _excludedUserIds.contains(x.id));
      }
    }
  }

  List<UserModel> _filterByName(List<UserModel> people, String query) {
    final filteredPeople = people
        .where((x) => x.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return filteredPeople;
  }
}
