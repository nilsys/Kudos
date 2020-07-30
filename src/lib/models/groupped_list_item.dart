import 'package:flutter/material.dart';

@immutable
class GrouppedListItem<T> {
  final String groupName;
  final int sortIndex;
  final T item;

  GrouppedListItem(this.groupName, this.sortIndex, this.item);
}
