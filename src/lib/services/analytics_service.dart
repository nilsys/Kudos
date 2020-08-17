import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';

class AnalyticsService {
  static final _analytics = FirebaseAnalytics();
  final NavigatorObserver observer =
      FirebaseAnalyticsObserver(analytics: _analytics);
}
