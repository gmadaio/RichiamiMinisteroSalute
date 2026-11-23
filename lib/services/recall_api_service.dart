import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/recall_item.dart';
import 'mock_recalls_repository.dart';

class RecallFetchException implements Exception {
  const RecallFetchException(this.message);
  final String message;

  @override
  String toString() => message;
}

class RecallApiService {
  RecallApiService({
    http.Client? client,
    this.feedUrl = '',
    this.useMockData = true,
  }) : _client = client ?? http.Client();

  final http.Client _client;

  /// Imposta [feedUrl] sull'endpoint /api/recalls del tuo server Node.js
  /// (es. https://tuo-backend.run.app/api/recalls) e imposta [useMockData] a false.
  final String feedUrl;
  final bool useMockData;

  Future<List<RecallItem>> fetchRecalls() async {
    if (useMockData || feedUrl.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 550));
      final items = MockRecallsRepository.getInitialRecalls();
      items.sort((a, b) => b.publicationDate.compareTo(a.publicationDate));
      return items;
    }

    try {
      final uri = Uri.parse(feedUrl);
      final response = await _client
          .get(
            uri,
            headers: const {
              'Accept': 'application/json',
              'User-Agent': 'RichiamiAlimentariIT/1.0',
            },
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw RecallFetchException(
          'Il server ha risposto con codice ${response.statusCode}.',
        );
      }

      final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> rawList;

      if (decoded is List) {
        rawList = decoded;
      } else if (decoded is Map<String, dynamic> && decoded['items'] is List) {
        rawList = decoded['items'] as List<dynamic>;
      } else {
        throw const RecallFetchException('Formato JSON non valido.');
      }

      final items = rawList
          .whereType<Map<String, dynamic>>()
          .map(RecallItem.fromJson)
          .toList();

      items.sort((a, b) => b.publicationDate.compareTo(a.publicationDate));
      return items;
    } on SocketException {
      throw const RecallFetchException(
        'Nessuna connessione Internet disponibile.',
      );
    } on TimeoutException {
      throw const RecallFetchException(
        'Tempo di attesa scaduto durante la connessione al feed.',
      );
    } on FormatException {
      throw const RecallFetchException(
        'Errore nella lettura dei dati ricevuti dal server.',
      );
    }
  }
}
