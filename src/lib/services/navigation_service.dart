import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/services/page_mapper_service.dart';
import 'package:kudosapp/viewmodels/base_viewmodel.dart';
import 'package:provider/provider.dart';

class NavigationService {
  final _pageMapperService = locator<PageMapperService>();

  Future<TResult> navigateTo<TViewModel extends BaseViewModel, TResult>(
    BuildContext context,
    TViewModel viewModel, {
    bool fullscreenDialog,
  }) {
    var page = _pageMapperService.getPage(viewModel);
    var wrappedPage = ChangeNotifierProvider(
      create: (context) => viewModel,
      child: page,
    );
    var pageName = _pageMapperService.getPageName(viewModel);

    var route = _getMaterialPageRoute<TResult>(
      wrappedPage,
      pageName,
      fullscreenDialog: fullscreenDialog,
    );

    return Navigator.of(context).push(route);
  }

  void pop<T>(BuildContext context, [T result]) =>
      Navigator.of(context).pop(result);

  MaterialPageRoute<T> _getMaterialPageRoute<T>(
    Widget page,
    String pageName, {
    bool fullscreenDialog,
  }) {
    return MaterialPageRoute<T>(
      settings: RouteSettings(name: pageName),
      builder: (context) => page,
      fullscreenDialog: fullscreenDialog ?? false,
    );
  }

  PageRouteBuilder<T> _getPageRouteBuilder<T>(
    Widget page,
    String pageName, {
    bool fullscreenDialog,
  }) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: pageName),
      fullscreenDialog: fullscreenDialog ?? false,
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          _getFadeTransition(animation, child),
    );
  }

  Widget _getFadeTransition(Animation<double> animation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  Widget _getSlideTransition(Animation<double> animation, Widget child) {
    var begin = Offset(0.0, 1.0);
    var end = Offset.zero;
    var curve = Curves.ease;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}
