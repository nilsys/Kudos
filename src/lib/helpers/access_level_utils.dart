import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kudosapp/models/access_level.dart';
import 'package:kudosapp/service_locator.dart';

class AccessLevelUtils {
  static List<AccessLevel> getAllAccessLevels() => [
        AccessLevel.public,
        AccessLevel.protected,
        AccessLevel.private,
      ];

  static AccessLevel fromString(String str) {
    if (str == localizer().accessLevelPublic)
      return AccessLevel.public;
    else if (str == localizer().accessLevelPrivate)
      return AccessLevel.private;
    else if (str == localizer().accessLevelProtected)
      return AccessLevel.protected;
    return null;
  }

  static String getString(AccessLevel accessLevel) {
    switch (accessLevel) {
      case AccessLevel.public:
        return localizer().accessLevelPublic;
      case AccessLevel.private:
        return localizer().accessLevelPrivate;
      case AccessLevel.protected:
        return localizer().accessLevelProtected;
      default:
        return null;
    }
  }

  static String getDescription(AccessLevel accessLevel) {
    switch (accessLevel) {
      case AccessLevel.public:
        return localizer().accessLevelPublicDescription;
      case AccessLevel.private:
        return localizer().accessLevelPrivateDescription;
      case AccessLevel.protected:
        return localizer().accessLevelProtectedDescription;
      default:
        return null;
    }
  }

  static IconData getIcon(AccessLevel accessLevel) {
    switch (accessLevel) {
      case AccessLevel.public:
        return Icons.lock_open;
      case AccessLevel.private:
        return Icons.lock;
      case AccessLevel.protected:
        return Icons.lock_outline;
      default:
        return null;
    }
  }
}
