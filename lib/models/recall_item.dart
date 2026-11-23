import 'package:flutter/foundation.dart';

enum RiskCategory {
  microbiologico,
  allergeni,
  chimico,
  fisico,
  altro;

  static RiskCategory fromString(String? raw) {
    final normalized = (raw ?? '').trim().toLowerCase();
    for (final value in RiskCategory.values) {
      if (value.name == normalized) {
        return value;
      }
    }
    if (normalized.contains('micro')) return RiskCategory.microbiologico;
    if (normalized.contains('allerg')) return RiskCategory.allergeni;
    if (normalized.contains('chim')) return RiskCategory.chimico;
    if (normalized.contains('fisic')) return RiskCategory.fisico;
    return RiskCategory.altro;
  }

  String get label {
    switch (this) {
      case RiskCategory.microbiologico:
        return 'Microbiologico';
      case RiskCategory.allergeni:
        return 'Allergeni';
      case RiskCategory.chimico:
        return 'Chimico';
      case RiskCategory.fisico:
        return 'Fisico';
      case RiskCategory.altro:
        return 'Altro';
    }
  }
}

@immutable
class RecallItem {
  const RecallItem({
    required this.id,
    required this.publicationDate,
    required this.productName,
    required this.brand,
    required this.manufacturer,
    required this.lotNumbers,
    required this.expirationDate,
    required this.packagingUnit,
    required this.reason,
    required this.riskCategory,
    required this.instructions,
    required this.officialSourceUrl,
    this.imageUrl,
  });

  final String id;
  final DateTime publicationDate;
  final String productName;
  final String brand;
  final String manufacturer;
  final List<String> lotNumbers;
  final String expirationDate;
  final String packagingUnit;
  final String reason;
  final RiskCategory riskCategory;
  final String instructions;
  final String officialSourceUrl;
  final String? imageUrl;

  bool get isNew {
    final difference = DateTime.now().difference(publicationDate).inDays;
    return difference <= 7;
  }

  bool matchesQuery(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return true;

    return productName.toLowerCase().contains(clean) ||
        brand.toLowerCase().contains(clean) ||
        manufacturer.toLowerCase().contains(clean) ||
        reason.toLowerCase().contains(clean) ||
        lotNumbers.any((lot) => lot.toLowerCase().contains(clean));
  }

  List<String> matchingKeywords(List<String> keywords) {
    if (keywords.isEmpty) return const [];
    final searchable = <String>[
      productName,
      brand,
      manufacturer,
      reason,
      instructions,
      ...lotNumbers,
    ].join(' ').toLowerCase();

    return keywords
        .where((kw) => kw.trim().isNotEmpty && searchable.contains(kw.trim().toLowerCase()))
        .toList(growable: false);
  }

  factory RecallItem.fromJson(Map<String, dynamic> json) {
    final rawLots = json['lotNumbers'];
    final parsedLots = rawLots is List
        ? rawLots.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList()
        : <String>[];

    final parsedDate = DateTime.tryParse(json['publicationDate']?.toString() ?? '') ??
        DateTime.now();

    return RecallItem(
      id: json['id']?.toString() ?? '',
      publicationDate: parsedDate,
      productName: json['productName']?.toString() ?? 'Prodotto non specificato',
      brand: json['brand']?.toString() ?? 'Marchio non indicato',
      manufacturer: json['manufacturer']?.toString() ?? 'Produttore non indicato',
      lotNumbers: parsedLots,
      expirationDate: json['expirationDate']?.toString() ?? 'Non specificata',
      packagingUnit: json['packagingUnit']?.toString() ?? 'Confezione standard',
      reason: json['reason']?.toString() ?? '',
      riskCategory: RiskCategory.fromString(json['riskCategory']?.toString()),
      instructions: json['instructions']?.toString() ?? '',
      officialSourceUrl: json['officialSourceUrl']?.toString() ??
          'https://www.salute.gov.it',
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'publicationDate': publicationDate.toIso8601String(),
      'productName': productName,
      'brand': brand,
      'manufacturer': manufacturer,
      'lotNumbers': lotNumbers,
      'expirationDate': expirationDate,
      'packagingUnit': packagingUnit,
      'reason': reason,
      'riskCategory': riskCategory.name,
      'instructions': instructions,
      'officialSourceUrl': officialSourceUrl,
      'imageUrl': imageUrl,
    };
  }
}
