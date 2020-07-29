import 'package:flutter/material.dart';
import 'package:kudosapp/kudos_theme.dart';

class GroupListItem extends StatelessWidget {
  final String name;

  GroupListItem(this.name);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        top: 24.0,
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
