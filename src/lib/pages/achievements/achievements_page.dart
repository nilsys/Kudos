import 'package:flutter/material.dart';
import 'package:kudosapp/kudos_theme.dart';
import 'package:kudosapp/models/achievement_model.dart';
import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/viewmodels/achievements/achievements_viewmodel.dart';
import 'package:kudosapp/widgets/achievements/achievement_list_item_widget.dart';
import 'package:kudosapp/widgets/decorations/top_decorator.dart';
import 'package:kudosapp/widgets/gradient_app_bar.dart';
import 'package:kudosapp/widgets/groupped_list_widget.dart';
import 'package:provider/provider.dart';

class AchievementsPage extends StatelessWidget {
  final Widget _content;

  AchievementsPage({
    @required bool showAddButton,
    Icon selectorIcon,
  }) : _content = _AchievementsContentPage(
          showAddButton,
          selectorIcon,
        );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: localizer().achievements,
        elevation: 0,
      ),
      body: _content,
    );
  }
}

class AchievementsTab extends StatelessWidget {
  final Widget _content;

  AchievementsTab({
    @required bool showAddButton,
    Icon selectorIcon,
  }) : _content = _AchievementsContentPage(
          showAddButton,
          selectorIcon,
        );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          _buildTopBar(context),
          Expanded(
            child: Container(
              color: KudosTheme.contentColor,
              child: _content,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: Colors.transparent,
      height: 56,
      child: Center(
        child: Text(
          localizer().achievements,
          textAlign: TextAlign.center,
          style: KudosTheme.appBarTitleTextStyle,
        ),
      ),
    );
  }
}

class _AchievementsContentPage extends StatelessWidget {
  final Icon _selectorIcon;
  final bool _showAddButton;

  _AchievementsContentPage(
    bool showAddButton,
    Icon selectorIcon,
  )   : _selectorIcon = selectorIcon,
        _showAddButton = showAddButton;

  @override
  Widget build(BuildContext context) {
    return TopDecorator.buildLayoutWithDecorator(
      Consumer<AchievementsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isBusy) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Consumer<AchievementsViewModel>(
                    builder: (context, viewModel, child) {
                      if (viewModel.achievements.isEmpty) {
                        return Center(
                          child: FractionallySizedBox(
                            widthFactor: 0.7,
                            child: Text(
                              localizer().createYourOwnAchievements,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      return GrouppedListWidget<AchievementModel>(
                        viewModel.achievements,
                        (a) => _buildListItem(
                          context,
                          viewModel,
                          a,
                        ),
                      );
                    },
                  ),
                ),
                Positioned.directional(
                  textDirection: TextDirection.ltr,
                  end: 16.0,
                  bottom: 32.0,
                  child: Visibility(
                    visible: _showAddButton,
                    child: FloatingActionButton(
                      onPressed: () => viewModel.createAchievement(context),
                      child: KudosTheme.addIcon,
                    ),
                  ),
                )
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    AchievementsViewModel viewModel,
    AchievementModel item,
  ) {
    return AchievementListItemWidget(
      item,
      (achievement) => viewModel.onAchievementClicked(context, achievement),
      _selectorIcon,
    );
  }
}
