import 'package:flutter/material.dart';
import 'package:kudosapp/kudos_theme.dart';

class GradientAppBar extends AppBar {
  GradientAppBar({String title, List<Widget> actions, double elevation})
      : super(
          title: Text(
            title ?? "",
            style: KudosTheme.appBarTitleTextStyle,
          ),
          elevation: elevation,
          actions: actions,
          backgroundColor: Colors.transparent,
          flexibleSpace: _buildGradientBackground(),
        );

  GradientAppBar.withWidget(Widget titleWidget,
      {List<Widget> actions, double elevation})
      : super(
          title: titleWidget,
          actions: actions,
          elevation: elevation,
          flexibleSpace: _buildGradientBackground(),
        );

  static Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(gradient: KudosTheme.mainGradient),
    );
  }
}
