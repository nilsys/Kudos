import 'package:kudosapp/models/user_model.dart';

abstract class BaseAuthService {
  UserModel get currentUser;

  void silentInit(void Function(UserModel) userChangedHandler);

  Future<void> signIn();

  Future<void> signOut();
}
