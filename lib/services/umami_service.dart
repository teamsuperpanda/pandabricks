import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pandabricks/services/logging.dart';

/// Analytics service. HTTP errors are silently caught and logged; no error propagation.
class UmamiService {
  UmamiService({
    this.endpoint = 'https://umami.teamsuperpanda.com/api/send',
    this.websiteId = '66c64ee2-bf2f-4b62-a0ea-8a732e1d665f',
    this.enabled = true,
  });

  final bool enabled;
  final String endpoint;
  final String websiteId;
  String _language = '';

  set language(String value) {
    _language = value;
  }

  void startSession() {
    if (!enabled) return;
    trackEvent('session:start');
  }

  void endSession() {
    if (!enabled) return;
    trackEvent('session:end');
  }

  void trackPageView(String path, {String? title}) {
    if (!enabled) return;
    _send('event', {
      'url': path,
      'event_name': 'pageview',
      if (title != null) 'title': title,
    });
  }

  void trackEvent(String event, {Map<String, String>? data}) {
    if (!enabled) return;
    _send('event', {
      'event_name': event,
      if (data != null) ...data,
    });
  }

  void _send(String type, Map<String, dynamic> payload) {
    unawaited(http
        .post(
          Uri.parse(endpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'type': type,
            'payload': {
              'website': websiteId,
              'language': _language,
              ...payload,
            },
          }),
        )
        .timeout(const Duration(seconds: 10))
        .then((_) => null)
        .catchError((Object e) {
          logError('UmamiService', e);
          return null;
        }));
  }
}

class UmamiNavigatorObserver extends NavigatorObserver {
  UmamiNavigatorObserver(this._umami);

  final UmamiService _umami;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _trackRoute(previousRoute);
    }
  }

  void _trackRoute(Route<dynamic> route) {
    if (route.settings.name != null) {
      final title = route.settings.name!.replaceAll(RegExp(r'[/\-_]'), ' ').trim();
      _umami.trackPageView(route.settings.name!, title: title);
    }
  }
}
