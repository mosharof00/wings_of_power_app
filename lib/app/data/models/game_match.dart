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
  final String? powerCode;
  final String? powerLabel;
  final String? heroName;

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
    this.powerCode,
    this.powerLabel,
    this.heroName,
  });

  factory GameMatchParticipant.fromJson(Map<String, dynamic> json) {
    final rawIsBot = json['isBot'] ?? json['is_bot'] ?? false;
    final isBotBool = rawIsBot is bool ? rawIsBot : rawIsBot.toString() == 'true';
    final rawNick = json['nickname']?.toString();
    final rawHero = json['hero'] is Map ? Map<String, dynamic>.from(json['hero'] as Map) : null;
    final pCode = json['powerCode']?.toString() ??
        json['power_code']?.toString() ??
        rawHero?['powerCode']?.toString() ??
        rawHero?['power_code']?.toString();
    final pLabel = json['powerLabel']?.toString() ??
        json['power_label']?.toString() ??
        rawHero?['powerLabel']?.toString() ??
        rawHero?['power_label']?.toString();
    final hName = json['heroName']?.toString() ??
        json['hero_name']?.toString() ??
        rawHero?['displayName']?.toString() ??
        rawHero?['display_name']?.toString() ??
        rawHero?['name']?.toString();

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
      powerCode: pCode,
      powerLabel: pLabel,
      heroName: hName,
    );
  }

  GameMatchParticipant copyWith({
    String? id,
    String? userId,
    String? nickname,
    String? avatarUrl,
    String? heroId,
    int? jerseyNumber,
    bool? isConnected,
    bool? isBot,
    String? leftAt,
    bool? powerUsed,
    String? powerCode,
    String? powerLabel,
    String? heroName,
  }) {
    return GameMatchParticipant(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      heroId: heroId ?? this.heroId,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      isConnected: isConnected ?? this.isConnected,
      isBot: isBot ?? this.isBot,
      leftAt: leftAt ?? this.leftAt,
      powerUsed: powerUsed ?? this.powerUsed,
      powerCode: powerCode ?? this.powerCode,
      powerLabel: powerLabel ?? this.powerLabel,
      heroName: heroName ?? this.heroName,
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
        if (powerCode != null) 'powerCode': powerCode,
        if (powerLabel != null) 'powerLabel': powerLabel,
        if (heroName != null) 'heroName': heroName,
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
  final bool canPass;
  final String? powerCode;
  final String? powerLabel;
  final List<String> usablePowers;

  const GameMatchYou({
    required this.participantId,
    this.canBuzz = false,
    this.powerUsed = false,
    this.heroId,
    this.jerseyNumber,
    this.canPass = false,
    this.powerCode,
    this.powerLabel,
    this.usablePowers = const [],
  });

  factory GameMatchYou.fromJson(Map<String, dynamic> json) {
    final rawPowers = json['usablePowers'] ?? json['usable_powers'];
    final usableList = rawPowers is List
        ? rawPowers.map((e) => e.toString()).toList()
        : const <String>[];

    return GameMatchYou(
      participantId: json['participantId']?.toString() ??
          json['participant_id']?.toString() ??
          '',
      canBuzz: (json['canBuzz'] ?? json['can_buzz'] ?? false) as bool,
      powerUsed: (json['powerUsed'] ?? json['power_used'] ?? false) as bool,
      heroId: json['heroId']?.toString() ?? json['hero_id']?.toString(),
      jerseyNumber: (json['jerseyNumber'] ?? json['jersey_number']) as int?,
      canPass: (json['canPass'] ?? json['can_pass'] ?? false) as bool,
      powerCode: json['powerCode']?.toString() ?? json['power_code']?.toString(),
      powerLabel: json['powerLabel']?.toString() ?? json['power_label']?.toString(),
      usablePowers: usableList,
    );
  }

  GameMatchYou copyWith({
    String? participantId,
    bool? canBuzz,
    bool? powerUsed,
    String? heroId,
    int? jerseyNumber,
    bool? canPass,
    String? powerCode,
    String? powerLabel,
    List<String>? usablePowers,
  }) {
    return GameMatchYou(
      participantId: participantId ?? this.participantId,
      canBuzz: canBuzz ?? this.canBuzz,
      powerUsed: powerUsed ?? this.powerUsed,
      heroId: heroId ?? this.heroId,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      canPass: canPass ?? this.canPass,
      powerCode: powerCode ?? this.powerCode,
      powerLabel: powerLabel ?? this.powerLabel,
      usablePowers: usablePowers ?? this.usablePowers,
    );
  }

  Map<String, dynamic> toJson() => {
        'participantId': participantId,
        'canBuzz': canBuzz,
        'powerUsed': powerUsed,
        'heroId': heroId,
        'jerseyNumber': jerseyNumber,
        'canPass': canPass,
        if (powerCode != null) 'powerCode': powerCode,
        if (powerLabel != null) 'powerLabel': powerLabel,
        'usablePowers': usablePowers,
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

class GameCountdownEvent {
  final String matchId;
  final DateTime? deadlineAt;
  final int value;

  const GameCountdownEvent({
    required this.matchId,
    this.deadlineAt,
    this.value = 3,
  });

  factory GameCountdownEvent.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic d) {
      if (d == null) return null;
      if (d is DateTime) return d;
      return DateTime.tryParse(d.toString());
    }

    return GameCountdownEvent(
      matchId: json['matchId']?.toString() ?? json['match_id']?.toString() ?? '',
      deadlineAt: parseDate(json['deadlineAt'] ?? json['deadline_at']),
      value: (json['value'] ?? 3) as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'matchId': matchId,
        'deadlineAt': deadlineAt?.toIso8601String(),
        'value': value,
      };
}

class GameRoundIntroEvent {
  final String roundType; // 'Q1_WARMUP'
  final String title; // 'Warm-Up Hoops'
  final String blurb; // 'Answer fast and earn balls for the Shootout'
  final DateTime? deadlineAt;

  const GameRoundIntroEvent({
    required this.roundType,
    required this.title,
    required this.blurb,
    this.deadlineAt,
  });

  factory GameRoundIntroEvent.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic d) {
      if (d == null) return null;
      if (d is DateTime) return d;
      return DateTime.tryParse(d.toString());
    }

    return GameRoundIntroEvent(
      roundType: json['roundType']?.toString() ?? json['round_type']?.toString() ?? 'Q1_WARMUP',
      title: json['title']?.toString() ?? 'Warm-Up Hoops',
      blurb: json['blurb']?.toString() ?? 'Answer fast and earn balls for the Shootout',
      deadlineAt: parseDate(json['deadlineAt'] ?? json['deadline_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'roundType': roundType,
        'title': title,
        'blurb': blurb,
        'deadlineAt': deadlineAt?.toIso8601String(),
      };
}

class GameQuestionEvent {
  final String roundId;
  final String prompt;
  final List<String> options;
  final String roundType;
  final int index;
  final int total;
  final DateTime? deadlineAt;

  const GameQuestionEvent({
    required this.roundId,
    required this.prompt,
    required this.options,
    this.roundType = 'Q1_WARMUP',
    this.index = 1,
    this.total = 5,
    this.deadlineAt,
  });

  factory GameQuestionEvent.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic d) {
      if (d == null) return null;
      if (d is DateTime) return d;
      return DateTime.tryParse(d.toString());
    }

    final rawOptions = json['options'] as List? ?? [];
    return GameQuestionEvent(
      roundId: json['roundId']?.toString() ?? json['round_id']?.toString() ?? '',
      prompt: json['prompt']?.toString() ?? '',
      options: rawOptions.map((e) => e.toString()).toList(),
      roundType: json['roundType']?.toString() ?? json['round_type']?.toString() ?? 'Q1_WARMUP',
      index: (json['index'] ?? 1) as int,
      total: (json['total'] ?? 5) as int,
      deadlineAt: parseDate(json['deadlineAt'] ?? json['deadline_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'roundId': roundId,
        'prompt': prompt,
        'options': options,
        'roundType': roundType,
        'index': index,
        'total': total,
        'deadlineAt': deadlineAt?.toIso8601String(),
      };
}

class GameBuzzWinnerEvent {
  final String roundId;
  final String participantId;
  final String userId;
  final DateTime? deadlineAt;

  const GameBuzzWinnerEvent({
    required this.roundId,
    required this.participantId,
    required this.userId,
    this.deadlineAt,
  });

  factory GameBuzzWinnerEvent.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic d) {
      if (d == null) return null;
      if (d is DateTime) return d;
      return DateTime.tryParse(d.toString());
    }

    return GameBuzzWinnerEvent(
      roundId: json['roundId']?.toString() ?? json['round_id']?.toString() ?? '',
      participantId: json['participantId']?.toString() ?? json['participant_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      deadlineAt: parseDate(json['deadlineAt'] ?? json['deadline_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'roundId': roundId,
        'participantId': participantId,
        'userId': userId,
        'deadlineAt': deadlineAt?.toIso8601String(),
      };
}

class GameWaitingEvent {
  final String roundId;
  final String reason; // OPPONENT or TEAMMATE
  final String? playerName;
  final String? teamLabel;

  const GameWaitingEvent({
    required this.roundId,
    required this.reason,
    this.playerName,
    this.teamLabel,
  });

  factory GameWaitingEvent.fromJson(Map<String, dynamic> json) {
    return GameWaitingEvent(
      roundId: json['roundId']?.toString() ?? json['round_id']?.toString() ?? '',
      reason: json['reason']?.toString() ?? 'OPPONENT',
      playerName: json['playerName']?.toString() ?? json['player_name']?.toString(),
      teamLabel: json['teamLabel']?.toString() ?? json['team_label']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'roundId': roundId,
        'reason': reason,
        'playerName': playerName,
        'teamLabel': teamLabel,
      };
}

class GameAnswerResultEvent {
  final String roundId;
  final String? userId;
  final String? participantId;
  final bool correct;
  final Map<String, dynamic> scores;
  final int kindnessDelta;
  final int? optionIndex;

  const GameAnswerResultEvent({
    required this.roundId,
    this.userId,
    this.participantId,
    required this.correct,
    this.scores = const {},
    this.kindnessDelta = 0,
    this.optionIndex,
  });

  factory GameAnswerResultEvent.fromJson(Map<String, dynamic> json) {
    final rawScores = json['scores'];
    return GameAnswerResultEvent(
      roundId: json['roundId']?.toString() ?? json['round_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString(),
      participantId: json['participantId']?.toString() ?? json['participant_id']?.toString(),
      correct: (json['correct'] ?? false) as bool,
      scores: rawScores is Map ? Map<String, dynamic>.from(rawScores) : const {},
      kindnessDelta: (json['kindnessDelta'] ?? json['kindness_delta'] ?? 0) as int,
      optionIndex: (json['optionIndex'] ?? json['option_index']) as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'roundId': roundId,
        'userId': userId,
        'participantId': participantId,
        'correct': correct,
        'scores': scores,
        'kindnessDelta': kindnessDelta,
        'optionIndex': optionIndex,
      };
}

class GameKindnessResultEvent {
  final String roundId;
  final String? userId;
  final String? participantId;
  final int kindnessDelta;
  final Map<String, dynamic> scores;
  final int? totalKindness;

  const GameKindnessResultEvent({
    required this.roundId,
    this.userId,
    this.participantId,
    this.kindnessDelta = 0,
    this.scores = const {},
    this.totalKindness,
  });

  factory GameKindnessResultEvent.fromJson(Map<String, dynamic> json) {
    final rawScores =
        json['scores'] ?? json['teamScores'] ?? json['team_scores'];
    return GameKindnessResultEvent(
      roundId: json['roundId']?.toString() ?? json['round_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString(),
      participantId: json['participantId']?.toString() ??
          json['participant_id']?.toString(),
      kindnessDelta: (json['kindnessDelta'] ??
          json['kindness_delta'] ??
          json['amount'] ??
          0) as int,
      scores: rawScores is Map
          ? Map<String, dynamic>.from(rawScores)
          : const {},
      totalKindness: (json['totalKindness'] ??
          json['total_kindness'] ??
          json['score_kindness']) as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'roundId': roundId,
        'userId': userId,
        'participantId': participantId,
        'kindnessDelta': kindnessDelta,
        'scores': scores,
        'totalKindness': totalKindness,
      };
}

class GameStealOpenEvent {
  final String roundId;
  final DateTime? deadlineAt;
  final String? eligibleTeamId;

  const GameStealOpenEvent({
    required this.roundId,
    this.deadlineAt,
    this.eligibleTeamId,
  });

  factory GameStealOpenEvent.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic d) {
      if (d == null) return null;
      if (d is DateTime) return d;
      return DateTime.tryParse(d.toString());
    }

    return GameStealOpenEvent(
      roundId: json['roundId']?.toString() ?? json['round_id']?.toString() ?? '',
      deadlineAt: parseDate(json['deadlineAt'] ?? json['deadline_at']),
      eligibleTeamId: json['eligibleTeamId']?.toString() ?? json['eligible_team_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'roundId': roundId,
        'deadlineAt': deadlineAt?.toIso8601String(),
        'eligibleTeamId': eligibleTeamId,
      };
}

class GameShootoutStartEvent {
  final String roundId;
  final String shooterParticipantId;
  final String shooterName;
  final DateTime? deadlineAt;
  final int multiplier;
  final String? matchId;

  const GameShootoutStartEvent({
    required this.roundId,
    required this.shooterParticipantId,
    required this.shooterName,
    this.deadlineAt,
    this.multiplier = 1,
    this.matchId,
  });

  factory GameShootoutStartEvent.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic d) {
      if (d == null) return null;
      if (d is DateTime) return d;
      return DateTime.tryParse(d.toString());
    }

    return GameShootoutStartEvent(
      roundId: json['roundId']?.toString() ?? json['round_id']?.toString() ?? '',
      shooterParticipantId: json['shooterParticipantId']?.toString() ??
          json['shooter_participant_id']?.toString() ??
          json['participantId']?.toString() ??
          '',
      shooterName: json['shooterName']?.toString() ??
          json['shooter_name']?.toString() ??
          json['nickname']?.toString() ??
          'Shooter',
      deadlineAt: parseDate(json['deadlineAt'] ?? json['deadline_at']),
      multiplier: (json['multiplier'] ?? 1) as int,
      matchId: json['matchId']?.toString() ?? json['match_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'roundId': roundId,
        'shooterParticipantId': shooterParticipantId,
        'shooterName': shooterName,
        'deadlineAt': deadlineAt?.toIso8601String(),
        'multiplier': multiplier,
        'matchId': matchId,
      };
}

class GameShootoutResultEvent {
  final String participantId;
  final bool made;
  final int xpEarned;
  final int scoreVsDelta;
  final int? teamAScoreVs;
  final int? teamBScoreVs;
  final Map<String, dynamic> teamScores;

  const GameShootoutResultEvent({
    required this.participantId,
    required this.made,
    this.xpEarned = 0,
    this.scoreVsDelta = 0,
    this.teamAScoreVs,
    this.teamBScoreVs,
    this.teamScores = const {},
  });

  factory GameShootoutResultEvent.fromJson(Map<String, dynamic> json) {
    final made = (json['made'] ?? false) as bool;
    final xp = (json['xpEarned'] ??
        json['xp_earned'] ??
        json['xp'] ??
        (made ? 2 : 0)) as int;
    final vsDelta = (json['scoreVsDelta'] ??
        json['score_vs_delta'] ??
        (made ? 3 : 0)) as int;
    final teamA = json['teamAScoreVs'] ?? json['team_a_score_vs'];
    final teamB = json['teamBScoreVs'] ?? json['team_b_score_vs'];
    final rawScores = json['teamScores'] ?? json['team_scores'] ?? json['scores'];

    return GameShootoutResultEvent(
      participantId: json['participantId']?.toString() ??
          json['participant_id']?.toString() ??
          '',
      made: made,
      xpEarned: xp,
      scoreVsDelta: vsDelta,
      teamAScoreVs: teamA is int
          ? teamA
          : (teamA != null ? int.tryParse('$teamA') : null),
      teamBScoreVs: teamB is int
          ? teamB
          : (teamB != null ? int.tryParse('$teamB') : null),
      teamScores: rawScores is Map
          ? Map<String, dynamic>.from(rawScores)
          : const {},
    );
  }

  Map<String, dynamic> toJson() => {
        'participantId': participantId,
        'made': made,
        'xpEarned': xpEarned,
        'scoreVsDelta': scoreVsDelta,
        'teamAScoreVs': teamAScoreVs,
        'teamBScoreVs': teamBScoreVs,
        'teamScores': teamScores,
      };
}

class GameRoundTeamSummary {
  final String name;
  final int scoreVs;
  final int coins;
  final int xp;

  const GameRoundTeamSummary({
    required this.name,
    this.scoreVs = 0,
    this.coins = 0,
    this.xp = 0,
  });

  factory GameRoundTeamSummary.fromJson(Map<String, dynamic> json) {
    return GameRoundTeamSummary(
      name: json['name']?.toString() ?? json['label']?.toString() ?? 'Team',
      scoreVs: (json['scoreVs'] ??
          json['score_vs'] ??
          json['baskets'] ??
          json['scoreBaskets'] ??
          0) as int,
      coins: (json['coins'] ??
          json['kindness'] ??
          json['scoreKindness'] ??
          0) as int,
      xp: (json['xp'] ?? json['scoreXp'] ?? json['xpEarned'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'scoreVs': scoreVs,
        'coins': coins,
        'xp': xp,
      };
}

class GameRoundCompleteEvent {
  final int roundNumber;
  final String? roundId;
  final String? roundType;
  final GameRoundTeamSummary teamA;
  final GameRoundTeamSummary teamB;
  final DateTime? deadlineAt;
  final Map<String, dynamic> rawData;

  const GameRoundCompleteEvent({
    this.roundNumber = 1,
    this.roundId,
    this.roundType,
    required this.teamA,
    required this.teamB,
    this.deadlineAt,
    this.rawData = const {},
  });

  factory GameRoundCompleteEvent.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic d) {
      if (d == null) return null;
      if (d is DateTime) return d;
      return DateTime.tryParse(d.toString());
    }

    GameRoundTeamSummary parseTeam(dynamic t, String fallbackName) {
      if (t is Map) {
        return GameRoundTeamSummary.fromJson(Map<String, dynamic>.from(t));
      }
      return GameRoundTeamSummary(name: fallbackName);
    }

    var teamA = parseTeam(json['teamA'] ?? json['team_a'], 'Team A');
    var teamB = parseTeam(json['teamB'] ?? json['team_b'], 'Team B');

    final teamScores = json['teamScores'] ?? json['team_scores'];
    if (teamScores is Map) {
      final keys = teamScores.keys.toList();
      if (keys.isNotEmpty && (json['teamA'] == null && json['team_a'] == null)) {
        final valA = teamScores[keys[0]];
        if (valA is Map) {
          teamA = GameRoundTeamSummary(
            name: valA['name']?.toString() ?? valA['label']?.toString() ?? 'Team A',
            scoreVs: (valA['scoreVs'] ?? valA['baskets'] ?? 0) as int,
            coins: (valA['coins'] ?? valA['kindness'] ?? 0) as int,
            xp: (valA['xp'] ?? 0) as int,
          );
        }
      }
      if (keys.length > 1 && (json['teamB'] == null && json['team_b'] == null)) {
        final valB = teamScores[keys[1]];
        if (valB is Map) {
          teamB = GameRoundTeamSummary(
            name: valB['name']?.toString() ?? valB['label']?.toString() ?? 'Team B',
            scoreVs: (valB['scoreVs'] ?? valB['baskets'] ?? 0) as int,
            coins: (valB['coins'] ?? valB['kindness'] ?? 0) as int,
            xp: (valB['xp'] ?? 0) as int,
          );
        }
      }
    }

    return GameRoundCompleteEvent(
      roundNumber: (json['roundNumber'] ?? json['round_number'] ?? 1) as int,
      roundId: json['roundId']?.toString() ?? json['round_id']?.toString(),
      roundType: json['roundType']?.toString() ?? json['round_type']?.toString(),
      teamA: teamA,
      teamB: teamB,
      deadlineAt: parseDate(json['deadlineAt'] ?? json['deadline_at']),
      rawData: json,
    );
  }

  Map<String, dynamic> toJson() => {
        'roundNumber': roundNumber,
        'roundId': roundId,
        'roundType': roundType,
        'teamA': teamA.toJson(),
        'teamB': teamB.toJson(),
        'deadlineAt': deadlineAt?.toIso8601String(),
      };
}

class GamePowerEffectEvent {
  final String roundId;
  final String? userId;
  final String? participantId;
  final String powerCode;
  final List<int>? removedOptions;
  final DateTime? deadlineAt;
  final int? extraMs;
  final String? hint;
  final List<num>? weights;
  final Map<String, dynamic> rawEffect;

  const GamePowerEffectEvent({
    required this.roundId,
    this.userId,
    this.participantId,
    required this.powerCode,
    this.removedOptions,
    this.deadlineAt,
    this.extraMs,
    this.hint,
    this.weights,
    this.rawEffect = const {},
  });

  factory GamePowerEffectEvent.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic d) {
      if (d == null) return null;
      if (d is DateTime) return d;
      return DateTime.tryParse(d.toString());
    }

    final rawEffect = json['effect'] is Map
        ? Map<String, dynamic>.from(json['effect'] as Map)
        : <String, dynamic>{};

    final pCode = json['powerCode']?.toString() ??
        json['power_code']?.toString() ??
        rawEffect['powerCode']?.toString() ??
        rawEffect['power_code']?.toString() ??
        '';

    // removedOptions
    List<int>? removed;
    final rawRemoved = json['removedOptions'] ??
        json['removed_options'] ??
        rawEffect['removedOptions'] ??
        rawEffect['removed_options'] ??
        (rawEffect['type'] == 'removedOptions' ? rawEffect['value'] : null);
    if (rawRemoved is List) {
      removed = rawRemoved
          .map((e) => (e is int) ? e : int.tryParse('$e'))
          .whereType<int>()
          .toList();
    }

    // extraMs
    int? extra;
    final rawExtra = json['extraMs'] ??
        json['extra_ms'] ??
        rawEffect['extraMs'] ??
        rawEffect['extra_ms'] ??
        (rawEffect['type'] == 'extraMs' ? rawEffect['value'] : null);
    if (rawExtra != null) {
      extra = (rawExtra is int) ? rawExtra : int.tryParse('$rawExtra');
    }

    // deadlineAt
    final deadline = parseDate(json['deadlineAt'] ??
        json['deadline_at'] ??
        rawEffect['deadlineAt'] ??
        rawEffect['deadline_at']);

    // hint
    String? hintText;
    final rawHint = json['hint'] ??
        rawEffect['hint'] ??
        (rawEffect['type'] == 'hint' ? rawEffect['value'] : null);
    if (rawHint != null) {
      hintText = rawHint.toString();
    }

    // weights
    List<num>? weightList;
    final rawWeights = json['weights'] ??
        rawEffect['weights'] ??
        (rawEffect['type'] == 'weights' ? rawEffect['value'] : null);
    if (rawWeights is List) {
      weightList = rawWeights
          .map((e) => (e is num) ? e : num.tryParse('$e'))
          .whereType<num>()
          .toList();
    }

    return GamePowerEffectEvent(
      roundId: json['roundId']?.toString() ?? json['round_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString(),
      participantId: json['participantId']?.toString() ?? json['participant_id']?.toString(),
      powerCode: pCode,
      removedOptions: removed,
      deadlineAt: deadline,
      extraMs: extra,
      hint: hintText,
      weights: weightList,
      rawEffect: rawEffect.isNotEmpty ? rawEffect : json,
    );
  }

  Map<String, dynamic> toJson() => {
        'roundId': roundId,
        'userId': userId,
        'participantId': participantId,
        'powerCode': powerCode,
        'removedOptions': removedOptions,
        'deadlineAt': deadlineAt?.toIso8601String(),
        'extraMs': extraMs,
        'hint': hint,
        'weights': weights,
        'effect': rawEffect,
      };
}

class HeroPowerInfo {
  final String heroCode;
  final String heroName;
  final String powerCode;
  final String powerLabel;
  final String description;
  final String bannerTitle;
  final String bannerSubtitle;
  final String assetPath;

  const HeroPowerInfo({
    required this.heroCode,
    required this.heroName,
    required this.powerCode,
    required this.powerLabel,
    required this.description,
    required this.bannerTitle,
    required this.bannerSubtitle,
    required this.assetPath,
  });

  static const List<HeroPowerInfo> all = [
    HeroPowerInfo(
      heroCode: 'FAITH',
      heroName: 'Faith',
      powerCode: 'MELODY',
      powerLabel: 'Melody Shot',
      description: 'Extra focus time',
      bannerTitle: 'Awesome!',
      bannerSubtitle: 'You got extra time! +10s',
      assetPath: 'assets/characters/hero_faith.png',
    ),
    HeroPowerInfo(
      heroCode: 'MICHELE',
      heroName: 'Michele',
      powerCode: 'COLOR',
      powerLabel: 'Color Shot',
      description: 'Freezes timer',
      bannerTitle: 'Awesome!',
      bannerSubtitle: 'Time is frozen! 10s',
      assetPath: 'assets/characters/hero_michele.png',
    ),
    HeroPowerInfo(
      heroCode: 'MICHAEL',
      heroName: 'Michael',
      powerCode: 'CHECKMATE',
      powerLabel: 'Checkmate Shot',
      description: 'Sees defense strategy',
      bannerTitle: 'Smart move!',
      bannerSubtitle: 'Smart move! One option eliminated!',
      assetPath: 'assets/characters/hero_michael.png',
    ),
    HeroPowerInfo(
      heroCode: 'SAMANTHA',
      heroName: 'Samantha',
      powerCode: 'HARMONY',
      powerLabel: 'Harmony Shot',
      description: 'Ask teammate for help',
      bannerTitle: 'Awesome!',
      bannerSubtitle: 'Your teammate is here to help!',
      assetPath: 'assets/characters/hero_samantha.png',
    ),
    HeroPowerInfo(
      heroCode: 'CHI_SUNG',
      heroName: 'Chi Sung',
      powerCode: 'PRISM',
      powerLabel: 'Prism Shot',
      description: 'Shows probability of answer',
      bannerTitle: 'Smart move!',
      bannerSubtitle: 'Probability calculated!',
      assetPath: 'assets/characters/hero_chi_sung.png',
    ),
    HeroPowerInfo(
      heroCode: 'RALPH',
      heroName: 'Ralph',
      powerCode: 'NATURE',
      powerLabel: 'Nature Shot',
      description: 'Reveals animal hint',
      bannerTitle: 'Awesome!',
      bannerSubtitle: 'Nature has a clue for you!',
      assetPath: 'assets/characters/hero_ralph.png',
    ),
    HeroPowerInfo(
      heroCode: 'HAROLD',
      heroName: 'Harold',
      powerCode: 'LAB',
      powerLabel: 'Lab Shot',
      description: 'Removes 2 wrong answer',
      bannerTitle: 'Smart move!',
      bannerSubtitle: 'Science to the rescue! Two options eliminated!',
      assetPath: 'assets/characters/hero_harold.png',
    ),
    HeroPowerInfo(
      heroCode: 'EVELYA',
      heroName: 'Evelya',
      powerCode: 'STORY',
      powerLabel: 'Story Shot',
      description: 'Your story clue is ready',
      bannerTitle: 'Awesome!',
      bannerSubtitle: 'Your story clue is ready!',
      assetPath: 'assets/characters/hero_evelya.png',
    ),
  ];

  static HeroPowerInfo? findByPowerCode(String? code) {
    if (code == null || code.isEmpty) return null;
    final upper = code.toUpperCase();
    for (final p in all) {
      if (p.powerCode.toUpperCase() == upper) return p;
    }
    return null;
  }

  static HeroPowerInfo? findByHeroIdOrCode(String? heroId) {
    if (heroId == null || heroId.isEmpty) return null;
    final lower = heroId.toLowerCase();
    for (final p in all) {
      if (p.heroCode.toLowerCase() == lower ||
          p.heroName.toLowerCase() == lower ||
          lower.contains(p.heroName.toLowerCase()) ||
          lower.contains(p.heroCode.toLowerCase())) {
        return p;
      }
    }
    return null;
  }
}
