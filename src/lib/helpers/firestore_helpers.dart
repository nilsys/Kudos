import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kudosapp/services/cache/item_change_type.dart';

extension DocumentChangeTypeParser on DocumentChangeType {
  ItemChangeType toItemChangeType() {
    switch (this) {
      case DocumentChangeType.modified:
        return ItemChangeType.change;
      case DocumentChangeType.removed:
        return ItemChangeType.remove;
      case DocumentChangeType.added:
      default:
        return ItemChangeType.add;
    }
  }
}
