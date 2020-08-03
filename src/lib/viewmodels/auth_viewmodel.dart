import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/services/achievements_service.dart';
import 'package:kudosapp/services/base_auth_service.dart';
import 'package:kudosapp/services/push_notifications_service.dart';
import 'package:kudosapp/services/users_service.dart';
import 'package:kudosapp/viewmodels/base_viewmodel.dart';

enum AuthViewModelState {
  unknown,
  loggedIn,
  loggedOut,
}

class AuthViewModel extends BaseViewModel {
  final _usersService = locator<UsersService>();
  final _authService = locator<BaseAuthService>();
  final _achievementsService = locator<AchievementsService>();
  final _pushNotificationsService = locator<PushNotificationsService>();

  AuthViewModelState _authState = AuthViewModelState.unknown;

  AuthViewModel() {
    _authService.silentInit((user) {
      authState = user == null
          ? AuthViewModelState.loggedOut
          : AuthViewModelState.loggedIn;
    });
  }

  AuthViewModelState get authState => _authState;

  set authState(AuthViewModelState state) {
    _authState = state;
    notifyListeners();
  }

  Future<void> signIn() async {
    await _authService.signIn();
    final pushToken =
        await _pushNotificationsService.subscribeForNotifications();
    await _usersService.tryRegisterCurrentUser(pushToken);
  }

  Future<void> signOut() async {
    await _pushNotificationsService.unsubscribeFromNotifications();
    _usersService.closeUsersSubscription();
    _achievementsService.closeAchievementsSubscription();
    await _authService.signOut();
  }
}
