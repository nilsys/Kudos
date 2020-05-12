import 'package:kudosapp/models/user.dart';
import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/services/base_auth_service.dart';
import 'package:kudosapp/services/people_service.dart';
import 'package:kudosapp/viewmodels/base_viewmodel.dart';

class AuthViewModel extends BaseViewModel {
  final BaseAuthService _authService = locator<BaseAuthService>();
  final PeopleService _peopleService = locator<PeopleService>();

  User _currentUser;

  AuthViewModel() {
    _authService.silentInit((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  User get currentUser => _currentUser;

  bool get isAuth => _currentUser != null;

  Future<void> signIn() async {
    await _authService.signIn();
    await _peopleService.tryRegisterUser(_authService.currentUser);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}