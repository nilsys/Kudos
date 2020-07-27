import 'package:flutter/material.dart';
import 'package:kudosapp/kudos_theme.dart';
import 'package:kudosapp/models/team_model.dart';
import 'package:kudosapp/models/user_model.dart';
import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/viewmodels/team_member_picker_viewmodel.dart';
import 'package:kudosapp/widgets/gradient_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:kudosapp/widgets/list_of_people_widget.dart';

class TeamMemberPickerRoute extends MaterialPageRoute {
  TeamMemberPickerRoute(
    TeamModel team, {
    String searchHint,
  }) : super(
          builder: (context) {
            return ChangeNotifierProvider<TeamMemberPickerViewModel>(
              create: (context) {
                return TeamMemberPickerViewModel(team);
              },
              child: _TeamMemberPickerPage(searchHint ?? localizer().search),
            );
          },
          fullscreenDialog: true,
        );
}

class _TeamMemberPickerPage extends StatefulWidget {
  final String _searchHint;

  _TeamMemberPickerPage(this._searchHint);

  @override
  State<StatefulWidget> createState() {
    return _TeamMemberPickerPageState();
  }
}

class _TeamMemberPickerPageState extends State<_TeamMemberPickerPage> {
  final _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var actions = List<Widget>();
    var viewModel = Provider.of<TeamMemberPickerViewModel>(
      context,
      listen: false,
    );

    actions.add(
      IconButton(
        onPressed: () => viewModel.saveChanges(context),
        icon: Icon(Icons.done),
      ),
    );

    return Scaffold(
      appBar: GradientAppBar.withWidget(
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: TextField(
            style: KudosTheme.searchTextStyle,
            cursorColor: KudosTheme.accentColor,
            controller: _textEditingController,
            decoration: InputDecoration.collapsed(
              hintText: widget._searchHint,
              hintStyle: KudosTheme.searchHintStyle,
            ),
            onChanged: (x) => viewModel.requestSearch(x),
          ),
        ),
        actions: actions,
      ),
      body: Consumer<TeamMemberPickerViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.users.isEmpty) {
            return Container();
          }
          return ListOfPeopleWidget(
            itemSelector: (x) => viewModel.onUserClicked(x),
            users: viewModel.users,
            trailingWidgetFunction: (user) =>
                _trailingWidgetFunc(viewModel, user),
          );
        },
      ),
    );
  }

  Widget _trailingWidgetFunc(
      TeamMemberPickerViewModel viewModel, UserModel user) {
    int state = viewModel.getUserState(user);
    switch (state) {
      case 0:
        return SizedBox(width: 1, height: 1);
      case 1:
        return Icon(Icons.people, color: KudosTheme.accentColor);
      case 2:
      default:
        return Icon(Icons.verified_user, color: KudosTheme.accentColor);
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
