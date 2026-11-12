// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/app_version.dart';

/// Place suggestions for the event location field, from the public
/// OpenStreetMap Nominatim search (no API key). Only the text typed in the
/// location field is sent, and only while typing in it.
class PlaceSearchService {
  PlaceSearchService._();

  static const _url = 'https://nominatim.openstreetmap.org/search';

  /// Required by the Nominatim usage policy (ignored by browsers on web).
  static const _headers = {
    'User-Agent': 'Noteep/$appVersion (+https://github.com/ndenicolais)',
  };

  /// The usage policy allows at most 1 request per second: every call waits
  /// here first, however close together they come.
  static DateTime? _lastRequest;
  static const _minGap = Duration(milliseconds: 1100);

  static Future<void> _throttle() async {
    final last = _lastRequest;
    if (last != null) {
      final elapsed = DateTime.now().difference(last);
      if (elapsed < _minGap) await Future.delayed(_minGap - elapsed);
    }
    _lastRequest = DateTime.now();
  }

  /// Up to 5 full addresses matching [query] (at least 3 characters), in
  /// [languageCode] when available. Silent on errors (offline, timeout):
  /// it is only a typing aid, an empty list leaves the free text as is.
  static Future<List<String>> search(String query, String languageCode) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return const [];
    try {
      await _throttle();
      final uri = Uri.parse(_url).replace(
        queryParameters: {
          'q': trimmed,
          'format': 'json',
          'limit': '5',
          'accept-language': languageCode,
        },
      );
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return const [];
      final results = jsonDecode(response.body);
      if (results is! List) return const [];
      return results
          .whereType<Map<String, dynamic>>()
          .map((r) => r['display_name'])
          .whereType<String>()
          .toSet()
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
