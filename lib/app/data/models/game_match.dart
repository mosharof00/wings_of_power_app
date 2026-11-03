class GameQueueRequest {
  final String mode;
  final String? fixtureCode;

  const GameQueueRequest({
    required this.mode,
    this.fixtureCode,
  });

  Map<String, dynamic> toJson() => {
        'mode': mode,
        if (fixtureCode != null && fixtureCode!.trim().isNotEmpty)
          'fixtureCode': fixtureCode!.trim(),
      };
}

class GameQueueResponse {
  final String? ticketId;
  final String? matchId;
  final String mode;

  const GameQueueResponse({
    this.ticketId,
    this.matchId,
    required this.mode,
  });

  factory GameQueueResponse.fromJson(Map<String, dynamic> json) {
    return GameQueueResponse(
      ticketId: json['ticketId']?.toString() ?? json['ticket_id']?.toString(),
      matchId: json['matchId']?.toString() ?? json['match_id']?.toString(),
      mode: json['mode']?.toString() ?? 'SINGLE',
    );
  }

  Map<String, dynamic> toJson() => {
        'ticketId': ticketId,
        'matchId': matchId,
        'mode': mode,
      };
}

class GameMatchParticipant {
  final String? id;
  final String? userId;
  final String? nickname;
  final String? avatarUrl;
  final String? heroId;
  final int? jerseyNumber;
  final bool isConnected;
  final bool isBot;
  final String? leftAt;
  final bool powerUsed;

  const GameMatchParticipant({
    this.id,
    this.userId,
    this.nickname,
    this.avatarUrl,
    this.heroId,
    this.jerseyNumber,
    this.isConnected = true,
    this.isBot = false,
    this.leftAt,
    this.powerUsed = false,
  });

  factory GameMatchParticipant.fromJson(Map<String, dynamic> json) {
    final rawIsBot = json['isBot'] ?? json['is_bot'] ?? false;
    final isBotBool = rawIsBot is bool ? rawIsBot : rawIsBot.toString() == 'true';
    final rawNick = json['nickname']?.toString();

    return GameMatchParticipant(
      id: json['id']?.toString() ?? json['participantId']?.toString(),
      userId: json['userId']?.toString() ?? json['user_id']?.toString(),
      nickname: rawNick ?? (isBotBool ? 'Practice Bot' : null),
      avatarUrl: json['avatarUrl']?.toString() ?? json['avatar_url']?.toString(),
      heroId: json['heroId']?.toString() ?? json['hero_id']?.toString(),
      jerseyNumber: (json['jerseyNumber'] ?? json['jersey_number']) as int?,
      isConnected: (json['isConnected'] ?? json['is_connected'] ?? true) as bool,
      isBot: isBotBool,
      leftAt: json['leftAt']?.toString() ?? json['left_at']?.toString(),
      powerUsed: (json['powerUsed'] ?? json['power_used'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'nickname': nickname,
        'avatarUrl': avatarUrl,
        'heroId': heroId,
        'jerseyNumber': jerseyNumber,
        'isConnected': isConnected,
        'isBot': isBot,
        'leftAt': leftAt,
        'powerUsed': powerUsed,
      };
}

class GameMatchTeam {
  final String id;
  final String label;
  final int scoreXp;
  final int scoreKindness;
  final int scoreBaskets;
  final List<GameMatchParticipant> members;

  const GameMatchTeam({
    required this.id,
    required this.label,
    this.scoreXp = 0,
    this.scoreKindness = 0,
    this.scoreBaskets = 0,
    this.members = const [],
  });

  factory GameMatchTeam.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'] as List? ?? [];
    return GameMatchTeam(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      scoreXp: (json['scoreXp'] ?? json['score_xp'] ?? 0) as int,
      scoreKindness: (json['scoreKindness'] ?? json['score_kindness'] ?? 0) as int,
      scoreBaskets: (json['scoreBaskets'] ?? json['score_baskets'] ?? 0) as int,
      members: rawMembers
          .map((m) =>
              GameMatchParticipant.fromJson(Map<String, dynamic>.from(m as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'scoreXp': scoreXp,
        'scoreKindness': scoreKindness,
        'scoreBaskets': scoreBaskets,
        'members': members.map((m) => m.toJson()).toList(),
      };
}

class GameMatchYou {
  final String participantId;
  final bool canBuzz;
  final bool powerUsed;
  final String? heroId;
  final int? jerseyNumber;

  const GameMatchYou({
    required this.participantId,
    this.canBuzz = false,
    this.powerUsed = false,
    this.heroId,
    this.jerseyNumber,
  });

  factory GameMatchYou.fromJson(Map<String, dynamic> json) {
    return GameMatchYou(
      participantId: json['participantId']?.toString() ??
          json['participant_id']?.toString() ??
          '',
      canBuzz: (json['canBuzz'] ?? json['can_buzz'] ?? false) as bool,
      powerUsed: (json['powerUsed'] ?? json['power_used'] ?? false) as bool,
      heroId: json['heroId']?.toString() ?? json['hero_id']?.toString(),
      jerseyNumber: (json['jerseyNumber'] ?? json['jersey_number']) as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'participantId': participantId,
        'canBuzz': canBuzz,
        'powerUsed': powerUsed,
        'heroId': heroId,
        'jerseyNumber': jerseyNumber,
      };
}

class GameMatchSnapshot {
  final String matchId;
  final String mode; // SINGLE, ONE_V_ONE, FIVE_V_FIVE
  final String phase; // COUNTDOWN, PLAYING, FINISHED, CANCELLED
  final String? roundType;
  final String? roundId;
  final DateTime? deadlineAt;
  final DateTime? serverNow;
  final List<GameMatchTeam> teams;
  final GameMatchYou? you;
  final Map<String, dynamic>? scores;

  const GameMatchSnapshot({
    required this.matchId,
    required this.mode,
    required this.phase,
    this.roundType,
    this.roundId,
    this.deadlineAt,
    this.serverNow,
    this.teams = const [],
    this.you,
    this.scores,
  });

  factory GameMatchSnapshot.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic d) {
      if (d == null) return null;
      if (d is DateTime) return d;
      return DateTime.tryParse(d.toString());
    }

    final rawTeams = json['teams'] as List? ?? [];
    return GameMatchSnapshot(
      matchId: json['matchId']?.toString() ??
          json['match_id']?.toString() ??
          '',
      mode: json['mode']?.toString() ?? 'SINGLE',
      phase: json['phase']?.toString() ?? 'COUNTDOWN',
      roundType: json['roundType']?.toString() ?? json['round_type']?.toString(),
      roundId: json['roundId']?.toString() ?? json['round_id']?.toString(),
      deadlineAt: parseDate(json['deadlineAt'] ?? json['deadline_at']),
      serverNow: parseDate(json['serverNow'] ?? json['server_now']),
      teams: rawTeams
          .map((t) => GameMatchTeam.fromJson(Map<String, dynamic>.from(t as Map)))
          .toList(),
      you: json['you'] != null
          ? GameMatchYou.fromJson(Map<String, dynamic>.from(json['you'] as Map))
          : null,
      scores: json['scores'] != null && json['scores'] is Map
          ? Map<String, dynamic>.from(json['scores'] as Map)
          : null,
    );
  }

  List<GameMatchParticipant> get allParticipants =>
      teams.expand((t) => t.members).toList();

  /// Opponents other than [yourUserId]
  List<GameMatchParticipant> opponents(String? yourUserId) {
    return allParticipants
        .where((p) => p.userId != yourUserId)
        .toList();
  }

  /// Opponent for solo practice: the bot seat or another player
  GameMatchParticipant botOrOpponent(String? yourUserId) {
    final bots = allParticipants.where((p) => p.isBot).toList();
    if (bots.isNotEmpty) return bots.first;
    final other = allParticipants.where((p) => p.userId != yourUserId).toList();
    if (other.isNotEmpty) return other.first;
    return const GameMatchParticipant(
      nickname: 'Practice Bot',
      isBot: true,
      jerseyNumber: 2,
    );
  }

  Map<String, dynamic> toJson() => {
        'matchId': matchId,
        'mode': mode,
        'phase': phase,
        'roundType': roundType,
        'roundId': roundId,
        'deadlineAt': deadlineAt?.toIso8601String(),
        'serverNow': serverNow?.toIso8601String(),
        'teams': teams.map((t) => t.toJson()).toList(),
        'you': you?.toJson(),
        'scores': scores,
      };
}

class GameQueueUpdate {
  final String mode;
  final int filled;
  final int required;
  final List<dynamic> players;

  const GameQueueUpdate({
    required this.mode,
    this.filled = 0,
    this.required = 0,
    this.players = const [],
  });

  factory GameQueueUpdate.fromJson(Map<String, dynamic> json) {
    return GameQueueUpdate(
      mode: json['mode']?.toString() ?? '',
      filled: (json['filled'] ?? 0) as int,
      required: (json['required'] ?? 0) as int,
      players: (json['players'] as List?) ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'mode': mode,
        'filled': filled,
        'required': required,
        'players': players,
      };
}
