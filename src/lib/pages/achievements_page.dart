import 'package:flutter/material.dart';
import 'package:kudosapp/models/achievement.dart';
import 'package:kudosapp/pages/achievement_details_page.dart';
import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/services/localization_service.dart';
import 'package:kudosapp/viewmodels/achievement_item_viewmodel.dart';
import 'package:kudosapp/viewmodels/achievements_viewmodel.dart';
import 'package:kudosapp/widgets/achievement_widget.dart';
import 'package:provider/provider.dart';

class AchievementsRoute extends MaterialPageRoute {
  AchievementsRoute()
      : super(
          builder: (context) {
            return ChangeNotifierProvider<AchievementsViewModel>(
              create: (context) => AchievementsViewModel()..initialize(),
              child: AchievementsPage(),
            );
          },
        );
}

class AchievementsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(locator<LocalizationService>().allAchievements),
      ),
      body: Consumer<AchievementsViewModel>(
        builder: (context, viewModel, child) {
          switch (viewModel.state) {
            case AchievementsViewModelState.busy:
              return Center(
                child: CircularProgressIndicator(),
              );
            case AchievementsViewModelState.ready:
              return _KudosListWidget.from(viewModel.achievements, (achievementItem) {
                Navigator.of(context).push(AchievementDetailsRoute(achievementItem.model));
              });
            default:
              throw UnimplementedError();
          }
        },
      ),
    );
  }
}

class _KudosListWidget extends StatelessWidget {
  final List<Widget> _items;

  factory _KudosListWidget.from(List<AchievementItemViewModel> input, 
  Function(AchievementItemViewModel) onAchievementClicked) {
    var sortedList = input.toList();
    sortedList
        .sort((x, y) => x.category.orderIndex.compareTo(y.category.orderIndex));

    String groupName;
    var items = List<Widget>();
    var achievements = List<AchievementItemViewModel>();
    var addFunction = (List<Widget> x, List<AchievementItemViewModel> y) {
      x.add(AchievementWidget(y.toList(), onAchievementClicked));
      y.clear();
    };

    for (var i = 0; i < sortedList.length; i++) {
      var item = sortedList[i];

      if (groupName != item.category.name) {
        if (achievements.isNotEmpty) {
          addFunction(items, achievements);
        }

        groupName = item.category.name;
        items.add(_GroupListItem(groupName));
      }

      achievements.add(item);

      if (achievements.length == 2) {
        addFunction(items, achievements);
      }

      if (i == sortedList.length - 1 && achievements.isNotEmpty) {
        addFunction(items, achievements);
      }
    }

    return _KudosListWidget._(items);
  }

  _KudosListWidget._(this._items);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return _items[index];
      },
      itemCount: _items.length,
    );
  }
}

class _GroupListItem extends StatelessWidget {
  final String name;

  _GroupListItem(this.name);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 40.0,
      ),
      child: Text(
        name,
        style: Theme.of(context).textTheme.title,
        textAlign: TextAlign.center,
      ),
    );
  }
}