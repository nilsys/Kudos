import 'package:flutter/material.dart';
import 'package:kudosapp/services/cache/item_change_type.dart';

@immutable
class ItemChange<T> {
  final T item;
  final ItemChangeType changeType;

  ItemChange(this.item, this.changeType);
}
