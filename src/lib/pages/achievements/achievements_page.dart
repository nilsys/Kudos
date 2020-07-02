import 'package:flutter/material.dart';
import 'package:kudosapp/dto/achievement.dart';
import 'package:kudosapp/extensions/list_extensions.dart';
import 'package:kudosapp/kudos_theme.dart';
import 'package:kudosapp/models/list_notifier.dart';
import 'package:kudosapp/pages/achievements/achievement_details_page.dart';
import 'package:kudosapp/pages/achievements/edit_achievement_page.dart';
import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/viewmodels/achievements/achievements_viewmodel.dart';
import 'package:kudosapp/widgets/achievements/achievement_list_item_widget.dart';
import 'package:kudosapp/widgets/decorations/bottom_decorator.dart';
import 'package:kudosapp/widgets/decorations/top_decorator.dart';
import 'package:kudosapp/widgets/gradient_app_bar.dart';
import 'package:provider/provider.dart';

class AchievementsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: localizer().achievements,
        elevation: 0,
      ),
      body: TopDecorator.buildLayoutWithDecorator(
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
                    child: ChangeNotifierProvider<ListNotifier<Achievement>>.value(
                      value: viewModel.achievements,
                      child: Consumer<ListNotifier<Achievement>>(
                        builder: (context, notifier, child) {
                          if (notifier.isEmpty) {
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

                          return _AchievementListWidget.from(
                            notifier.items,
                            (x) {
                              Navigator.of(context).push(
                                AchievementDetailsRoute(x.id, x.imageUrl),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned.directional(
                    textDirection: TextDirection.ltr,
                    end: 16.0,
                    bottom: 32.0,
                    child: FloatingActionButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          EditAchievementRoute.createUserAchievement(
                            viewModel.currentUser,
                          ),
                        );
                      },
                      child: Icon(Icons.add),
                    ),
                  )
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class _AchievementListWidget extends StatelessWidget {
  final List<Widget> _items;

  factory _AchievementListWidget.from(
    List<Achievement> input,
    void Function(Achievement) onAchievementClicked,
  ) {
    final sortedList = input.toList();
    sortedList.sortThen(
      (x, y) {
        if (x.teamReference == null && y.teamReference != null) {
          return -1;
        } else if (x.teamReference != null && y.teamReference == null) {
          return 1;
        } else {
          return 0;
        }
      },
      (x, y) {
        if (x.teamReference == null && y.teamReference == null) {
          return 0;
        }

        return x.teamReference.name.compareTo(y.teamReference.name);
      },
    );

    final myAchievementsText = localizer().myAchievements;
    final listItems = List<Widget>();
    String groupName;

    for (var i = 0; i < sortedList.length; i++) {
      final item = sortedList[i];
      final itemGroup = item.teamReference == null ? myAchievementsText : item.teamReference.name;
      if (groupName != itemGroup) {
        groupName = itemGroup;
        listItems.add(_GroupListItem(itemGroup));
      }
      listItems.add(AchievementListItemWidget(item, onAchievementClicked));
    }

    return _AchievementListWidget._(listItems);
  }

  _AchievementListWidget._(this._items);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return _items[index];
      },
      itemCount: _items.length,
      padding: EdgeInsets.only(
        top: TopDecorator.height,
        bottom: BottomDecorator.height,
      ),
    );
  }
}

class _GroupListItem extends StatelessWidget {
  final String name;

  _GroupListItem(this.name);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        top: 16.0,
        bottom: 16.0,
      ),
      child: Text(
        name,
        style: KudosTheme.listGroupTitleTextStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
