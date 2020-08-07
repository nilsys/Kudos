import 'package:flutter/material.dart';
import 'package:kudosapp/kudos_theme.dart';
import 'package:kudosapp/models/selection_action.dart';
import 'package:kudosapp/models/user_model.dart';
import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/viewmodels/users_viewmodel.dart';
import 'package:kudosapp/viewmodels/search_input_viewmodel.dart';
import 'package:kudosapp/widgets/decorations/bottom_decorator.dart';
import 'package:kudosapp/widgets/decorations/top_decorator.dart';
import 'package:kudosapp/widgets/gradient_app_bar.dart';
import 'package:kudosapp/widgets/list_of_people_widget.dart';
import 'package:kudosapp/widgets/search_input_widget.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';

class UsersPage extends StatelessWidget {
  final Widget _content;

  UsersPage({
    @required SelectionAction selectionAction,
    Set<String> excludedUserIds,
    Icon selectorIcon,
  }) : _content = new _UsersContentWidget(
          selectionAction,
          excludedUserIds,
          selectorIcon,
        );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: localizer().people, elevation: 0),
      body: _content,
    );
  }
}

class UsersTab extends StatelessWidget {
  final Widget _content;

  UsersTab({
    @required SelectionAction selectionAction,
    Set<String> excludedUserIds,
    Icon selectorIcon,
  }) : _content = new _UsersContentWidget(
          selectionAction,
          excludedUserIds,
          selectorIcon,
        );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: KudosTheme.contentColor,
        child: _content,
      ),
    );
  }
}

class _UsersContentWidget extends StatelessWidget {
  final Set<String> _excludedUserIds;
  final SelectionAction _selectionAction;
  final Icon _selectorIcon;

  _UsersContentWidget(
    SelectionAction selectionAction,
    Set<String> excludedUserIds,
    Icon selectorIcon,
  )   : _excludedUserIds = excludedUserIds,
        _selectorIcon = selectorIcon ?? KudosTheme.defaultSelectorIcon,
        _selectionAction = selectionAction;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SearchInputViewModel>(
      create: (context) => SearchInputViewModel(),
      child: ChangeNotifierProxyProvider<SearchInputViewModel, UsersViewModel>(
        create: (context) => UsersViewModel(
          _selectionAction,
          excludedUserIds: _excludedUserIds,
        ),
        update: (context, searchViewModel, peopleViewModel) =>
            peopleViewModel..filterByName(searchViewModel.query),
        child: Column(
          children: <Widget>[
            _buildSearchBar(),
            Expanded(
              child: TopDecorator.buildLayoutWithDecorator(
                Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: Consumer<UsersViewModel>(
                        builder: (context, viewModel, child) {
                          return StreamBuilder<List<UserModel>>(
                            stream: viewModel.peopleStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data.isEmpty) {
                                  return _buildEmpty();
                                }
                                return _buildList(
                                  context,
                                  viewModel,
                                  snapshot.data,
                                );
                              }
                              if (snapshot.hasError) {
                                return _buildError(snapshot.error);
                              }
                              return _buildLoading();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(gradient: KudosTheme.mainGradient),
      child: SearchInputWidget(
        hintText: localizer().enterName,
        iconSize: 82,
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Text(
        sprintf(localizer().detailedError, [error]),
        style: KudosTheme.errorTextStyle,
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Text(
        localizer().searchEmptyPlaceholder,
        style: KudosTheme.sectionEmptyTextStyle,
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    UsersViewModel viewModel,
    List<UserModel> users,
  ) {
    return ListOfPeopleWidget(
      padding: EdgeInsets.only(
        top: TopDecorator.height,
        bottom: BottomDecorator.height,
      ),
      itemSelector: (user) => viewModel.onItemClicked(context, user),
      users: users,
      trailingWidget: _selectorIcon,
    );
  }
}
