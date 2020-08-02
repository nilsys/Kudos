import 'package:flutter/cupertino.dart';
import 'package:kudosapp/kudos_theme.dart';
import 'package:kudosapp/models/user_model.dart';
import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/services/achievements_service.dart';
import 'package:kudosapp/services/base_auth_service.dart';
import 'package:kudosapp/services/push_notifications_service.dart';
import 'package:kudosapp/services/dialog_service.dart';
import 'package:kudosapp/viewmodels/base_viewmodel.dart';

class MyProfileViewModel extends BaseViewModel {
  final _authService = locator<BaseAuthService>();
  final _dialogService = locator<DialogService>();
  final _achievementsService = locator<AchievementsService>();
  final _pushNotificationsService = locator<PushNotificationsService>();

  UserModel get user => _authService.currentUser;

  void signOut(BuildContext context) async {
    var signOutConfirmed = await _dialogService.showTwoButtonsDialog(
      context: context,
      title: localizer().signOutConfirmationTitle,
      content: localizer().signOutConfirmationMessage,
      firstButtonTitle: localizer().signOutConfirmButton,
      secondButtonTitle: localizer().signOutCancelButton,
      firstButtonColor: KudosTheme.destructiveButtonColor,
    );
    if (signOutConfirmed) {
      await _pushNotificationsService.unsubscribeFromNotifications();
      _achievementsService.closeAchievementsSubscription();
      await _authService.signOut();
    }
  }
}
