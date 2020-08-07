import 'package:flutter/material.dart';
import 'package:kudosapp/kudos_theme.dart';
import 'package:kudosapp/widgets/gradient_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:kudosapp/viewmodels/user_picker_viewmodel.dart';
import 'package:kudosapp/widgets/list_of_people_widget.dart';

class UserPickerPage extends StatefulWidget {
  final String _searchHint;
  final WidgetBuilder _trailingBuilder;

  UserPickerPage(this._trailingBuilder, this._searchHint);

  @override
  State<StatefulWidget> createState() {
    return _UserPickerPageState();
  }
}

class _UserPickerPageState extends State<UserPickerPage> {
  final _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var viewModel = Provider.of<UserPickerViewModel>(
      context,
      listen: false,
    );

    var actions = List<Widget>();
    if (viewModel.allowMultipleSelection) {
      actions.add(
        IconButton(
          onPressed: () => viewModel.trySaveResult(context),
          icon: Icon(Icons.done),
        ),
      );
    }

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
      body: Consumer<UserPickerViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.users.isEmpty) {
            return Container();
          }
          return ListOfPeopleWidget(
            itemSelector: (user) =>
                viewModel.toggleUserSelection(context, user),
            users: viewModel.users,
            trailingWidgetFunction: (x) => widget._trailingBuilder != null
                ? widget._trailingBuilder(context)
                : viewModel.isUserSelected(x)
                    ? Icon(Icons.clear,
                        color: KudosTheme.destructiveButtonColor)
                    : Icon(Icons.add, color: KudosTheme.accentColor),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
