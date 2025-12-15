// To parse this JSON data, do
//
//     final giveaways = giveawayListFromJson(jsonString);

import 'dart:convert';

List<Giveaway> giveawayListFromJson(String str) {
  final raw = json.decode(str);
  if (raw is! List) {
    throw const FormatException('Expected a list of giveaways');
  }
  return raw
      .whereType<Map<String, dynamic>>()
      .map(Giveaway.fromJson)
      .toList(growable: false);
}

String giveawayListToJson(List<Giveaway> data) =>
    json.encode(data.map((x) => x.toJson()).toList(growable: false));

class Giveaway {
  const Giveaway({
    required this.id,
    required this.title,
    required this.worth,
    required this.thumbnail,
    required this.image,
    required this.description,
    required this.instructions,
    required this.openGiveawayUrl,
    required this.publishedDate,
    required this.type,
    required this.platforms,
    required this.endDate,
    required this.users,
    required this.status,
    required this.gamerpowerUrl,
    required this.openGiveaway,
  });

  final int id;
  final String title;
  final String worth;
  final String thumbnail;
  final String image;
  final String description;
  final String instructions;
  final String openGiveawayUrl;
  final DateTime? publishedDate;
  final GiveawayType type;
  final String platforms;
  final DateTime? endDate;
  final int users;
  final GiveawayStatus status;
  final String gamerpowerUrl;
  final String openGiveaway;

  factory Giveaway.fromJson(Map<String, dynamic> json) => Giveaway(
        id: _parseInt(json['id']),
        title: json['title'] as String? ?? '',
        worth: json['worth'] as String? ?? 'N/A',
        thumbnail: json['thumbnail'] as String? ?? '',
        image: json['image'] as String? ?? '',
        description: json['description'] as String? ?? '',
        instructions: json['instructions'] as String? ?? '',
        openGiveawayUrl: json['open_giveaway_url'] as String? ?? '',
        publishedDate: _parseDate(json['published_date']),
        type: _parseType(json['type']),
        platforms: json['platforms'] as String? ?? '',
        endDate: _parseDate(json['end_date']),
        users: _parseInt(json['users']),
        status: _parseStatus(json['status']),
        gamerpowerUrl: json['gamerpower_url'] as String? ?? '',
        openGiveaway: json['open_giveaway'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'worth': worth,
        'thumbnail': thumbnail,
        'image': image,
        'description': description,
        'instructions': instructions,
        'open_giveaway_url': openGiveawayUrl,
        'published_date': publishedDate?.toIso8601String(),
        'type': type.name,
        'platforms': platforms,
        'end_date': endDate?.toIso8601String(),
        'users': users,
        'status': status.name,
        'gamerpower_url': gamerpowerUrl,
        'open_giveaway': openGiveaway,
      };
}

enum GiveawayType { dlc, earlyAccess, game, bundle, other }

enum GiveawayStatus { active, upcoming, expired, unknown }

GiveawayType _parseType(dynamic value) {
  final raw = (value as String?)?.trim().toLowerCase();
  switch (raw) {
    case 'dlc':
      return GiveawayType.dlc;
    case 'early access':
      return GiveawayType.earlyAccess;
    case 'game':
      return GiveawayType.game;
    case 'bundle':
      return GiveawayType.bundle;
    default:
      return GiveawayType.other;
  }
}

GiveawayStatus _parseStatus(dynamic value) {
  final raw = (value as String?)?.trim().toLowerCase();
  switch (raw) {
    case 'active':
      return GiveawayStatus.active;
    case 'upcoming':
      return GiveawayStatus.upcoming;
    case 'expired':
      return GiveawayStatus.expired;
    default:
      return GiveawayStatus.unknown;
  }
}

int _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  if (value is num) {
    return value.round();
  }
  return 0;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'n/a') {
      return null;
    }
    final normalised = trimmed.contains('T')
        ? trimmed
        : trimmed.replaceFirst(' ', 'T');
    return DateTime.tryParse(normalised);
  }
  return null;
}
