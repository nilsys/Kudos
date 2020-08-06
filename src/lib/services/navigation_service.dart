import 'package:flutter/widgets.dart';
import 'package:kudosapp/viewmodels/base_viewmodel.dart';
import 'package:provider/provider.dart';

class NavigationService {
  void pop<T>(BuildContext context, [T result]) =>
      Navigator.of(context).pop(result);

  Future<T> navigateTo<T>(BuildContext context, Widget page) =>
      Navigator.of(context).push(_getPageRouteBuilder(page));

  Future navigateToViewModel<T extends BaseViewModel>(
    BuildContext context,
    Widget page,
    T viewModel,
  ) {
    var wrappedPage = ChangeNotifierProvider<T>(
      create: (context) => viewModel,
      child: page,
    );
    return navigateTo(context, wrappedPage);
  }

  PageRouteBuilder<T> _getPageRouteBuilder<T>(Widget page) {
    return PageRouteBuilder(
      fullscreenDialog: true,
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity:
              animation, // CurvedAnimation(parent: animation, curve: Curves.elasticInOut),
          child: child,
        );
      },
    );
  }
}
