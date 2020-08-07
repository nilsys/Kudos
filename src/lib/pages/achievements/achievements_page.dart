import 'package:flutter/material.dart';
import 'package:kudosapp/kudos_theme.dart';
import 'package:kudosapp/models/achievement_model.dart';
import 'package:kudosapp/models/selection_action.dart';
import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/viewmodels/achievements/achievements_viewmodel.dart';
import 'package:kudosapp/widgets/achievements/achievement_list_item_widget.dart';
import 'package:kudosapp/widgets/decorations/top_decorator.dart';
import 'package:kudosapp/widgets/gradient_app_bar.dart';
import 'package:kudosapp/widgets/groupped_list_widget.dart';
import 'package:provider/provider.dart';

class AchievementsPage extends StatelessWidget {
  final bool Function(AchievementModel) _achievementsFilter;
  final SelectionAction _selectionAction;
  final Icon _selectorIcon;
  final bool _showAddButton;

  AchievementsPage({
    @required SelectionAction selectionAction,
    @required bool showAddButton,
    bool Function(AchievementModel) achievementsFilter,
    Icon selectorIcon,
  })  : _achievementsFilter = achievementsFilter,
        _selectorIcon = selectorIcon,
        _selectionAction = selectionAction,
        _showAddButton = showAddButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: localizer().achievements,
        elevation: 0,
      ),
      body: ChangeNotifierProvider<AchievementsViewModel>(
        create: (context) => AchievementsViewModel(
          _selectionAction,
          achievementsFilter: _achievementsFilter,
        ),
        child: TopDecorator.buildLayoutWithDecorator(
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
        ),
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
