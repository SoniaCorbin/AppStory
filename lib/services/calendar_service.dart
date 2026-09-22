import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:http/http.dart' as http;

class CalendarService {
  static final _googleSignIn = GoogleSignIn(
    scopes: [gcal.CalendarApi.calendarReadonlyScope],
  );

  static GoogleSignInAccount? _currentUser;

  static Future<bool> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      return _currentUser != null;
    } catch (e) {
      debugPrint('Google Sign In error: $e');
      return false;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
  }

  static bool get isSignedIn => _currentUser != null;

  static Future<List<gcal.Event>> getUpcomingEvents({int maxResults = 10}) async {
    if (_currentUser == null) return [];

    try {
      final headers = await _currentUser!.authHeaders;
      final client = _AuthClient(headers);
      final calendarApi = gcal.CalendarApi(client);

      final events = await calendarApi.events.list(
        'primary',
        maxResults: maxResults,
        timeMin: DateTime.now(),
        singleEvents: true,
        orderBy: 'startTime',
      );

      return events.items ?? [];
    } catch (e) {
      debugPrint('Calendar error: $e');
      return [];
    }
  }
}

class _AuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _AuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}