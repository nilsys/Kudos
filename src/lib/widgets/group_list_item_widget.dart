import 'package:flutter/material.dart';
import 'package:kudosapp/kudos_theme.dart';

class GroupListItemWidget extends StatelessWidget {
  final String _name;

  GroupListItemWidget(this._name);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        top: 16.0,
        bottom: 16.0,
      ),
      child: Text(
        _name,
        style: KudosTheme.listGroupTitleTextStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
