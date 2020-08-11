import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kudosapp/kudos_theme.dart';
import 'package:kudosapp/models/team_model.dart';
import 'package:kudosapp/models/user_model.dart';
import 'package:kudosapp/service_locator.dart';
import 'package:kudosapp/viewmodels/teams/team_member_picker_viewmodel.dart';
import 'package:kudosapp/widgets/gradient_app_bar.dart';
import 'package:kudosapp/widgets/list_of_people_widget.dart';
import 'package:provider/provider.dart';

class TeamMemberPickerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TeamMemberPickerPageState();
  }
}

class _TeamMemberPickerPageState extends State<TeamMemberPickerPage> {
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
              hintText: localizer().searchMembers,
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
            return Center(
              child: Text(localizer().searchEmptyPlaceholder,
                  style: KudosTheme.sectionEmptyTextStyle),
            );
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
    TeamMemberPickerViewModel viewModel,
    UserModel user,
  ) {
    var state = viewModel.getUserState(user);
    switch (state) {
      case UserState.None:
        return SizedBox(width: 1, height: 1);
      case UserState.Member:
        return Icon(
          Icons.person,
          size: 32,
          color: KudosTheme.accentColor,
        );
      case UserState.Admin:
      default:
        return SvgPicture.asset("assets/icons/crown.svg",
            width: 32, height: 32);
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
