import 'package:wings_of_power_app/app/data/models/game_match.dart';

class GameMatchFinishedTeam {
  final String id;
  final String label;
  final int scoreVs;
  final int coins;
  final int xp;
  final List<GameMatchParticipant> members;

  const GameMatchFinishedTeam({
    required this.id,
    required this.label,
    this.scoreVs = 0,
    this.coins = 0,
    this.xp = 0,
    this.members = const [],
  });

  factory GameMatchFinishedTeam.fromJson(
    Map<String, dynamic> json, [
    List<GameMatchParticipant>? fallbackMembers,
  ]) {
    final rawMembers = json['members'] ?? json['roster'];
    List<GameMatchParticipant> memberList = [];
    if (rawMembers is List && rawMembers.isNotEmpty) {
      memberList = rawMembers
          .map((m) =>
              GameMatchParticipant.fromJson(Map<String, dynamic>.from(m as Map)))
          .toList();
    } else if (fallbackMembers != null && fallbackMembers.isNotEmpty) {
      memberList = fallbackMembers;
    }

    return GameMatchFinishedTeam(
      id: json['id']?.toString() ?? json['teamId']?.toString() ?? '',
      label: json['label']?.toString() ?? json['name']?.toString() ?? 'Team',
      scoreVs: (json['scoreVs'] ??
          json['score_vs'] ??
          json['baskets'] ??
          json['scoreBaskets'] ??
          0) as int,
      coins: (json['coins'] ??
          json['scoreKindness'] ??
          json['score_kindness'] ??
          json['kindness'] ??
          0) as int,
      xp: (json['xp'] ?? json['scoreXp'] ?? json['score_xp'] ?? 0) as int,
      members: memberList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'scoreVs': scoreVs,
        'coins': coins,
        'xp': xp,
        'members': members.map((m) => m.toJson()).toList(),
      };
}

class GameMatchFinishedEvent {
  final String matchId;
  final String? winnerTeamId;
  final String? winnerTeamLabel;
  final bool isTie;
  final GameMatchFinishedTeam? teamA;
  final GameMatchFinishedTeam? teamB;
  final Map<String, dynamic>? scores;
  final Map<String, dynamic>? kindness;

  const GameMatchFinishedEvent({
    required this.matchId,
    this.winnerTeamId,
    this.winnerTeamLabel,
    this.isTie = false,
    this.teamA,
    this.teamB,
    this.scores,
    this.kindness,
  });

  factory GameMatchFinishedEvent.fromJson(
    Map<String, dynamic> json, [
    List<GameMatchTeam>? snapshotTeams,
  ]) {
    final mId = json['matchId']?.toString() ?? json['match_id']?.toString() ?? '';
    final rawWinnerId =
        json['winnerTeamId']?.toString() ?? json['winner_team_id']?.toString();
    final wId = (rawWinnerId == null ||
            rawWinnerId.isEmpty ||
            rawWinnerId == 'null')
        ? null
        : rawWinnerId;

    var wLabel = json['winnerTeamLabel']?.toString() ??
        json['winner_team_label']?.toString();
    if (wLabel == 'null' || wLabel == '') wLabel = null;

    final explicitTie = json['isTie'] ?? json['is_tie'];
    final bool isTie = explicitTie is bool
        ? explicitTie
        : (explicitTie?.toString() == 'true' || wId == null);

    GameMatchFinishedTeam? tA;
    GameMatchFinishedTeam? tB;

    if (json['teamA'] is Map) {
      tA = GameMatchFinishedTeam.fromJson(
        Map<String, dynamic>.from(json['teamA'] as Map),
        snapshotTeams != null && snapshotTeams.isNotEmpty
            ? snapshotTeams[0].members
            : null,
      );
    }
    if (json['teamB'] is Map) {
      tB = GameMatchFinishedTeam.fromJson(
        Map<String, dynamic>.from(json['teamB'] as Map),
        snapshotTeams != null && snapshotTeams.length > 1
            ? snapshotTeams[1].members
            : null,
      );
    }

    // Fallback if teamA / teamB were not direct maps
    if (tA == null && snapshotTeams != null && snapshotTeams.isNotEmpty) {
      final team0 = snapshotTeams[0];
      final teamScores =
          json['scores'] is Map ? json['scores'][team0.id] : null;
      final teamKindness =
          json['kindness'] is Map ? json['kindness'][team0.id] : null;
      final rawXp = teamScores is Map ? teamScores['xp'] : null;
      final rawBaskets =
          teamScores is Map ? teamScores['baskets'] : null;
      final rawCoins = teamKindness is int ? teamKindness : null;
      final xp = rawXp is int ? rawXp : team0.scoreXp;
      final baskets = rawBaskets is int ? rawBaskets : team0.scoreBaskets;
      final coins = rawCoins ?? team0.scoreKindness;
      tA = GameMatchFinishedTeam(
        id: team0.id,
        label: team0.label,
        scoreVs: baskets,
        coins: coins,
        xp: xp,
        members: team0.members,
      );
    }

    if (tB == null && snapshotTeams != null && snapshotTeams.length > 1) {
      final team1 = snapshotTeams[1];
      final teamScores =
          json['scores'] is Map ? json['scores'][team1.id] : null;
      final teamKindness =
          json['kindness'] is Map ? json['kindness'][team1.id] : null;
      final rawXp = teamScores is Map ? teamScores['xp'] : null;
      final rawBaskets =
          teamScores is Map ? teamScores['baskets'] : null;
      final rawCoins = teamKindness is int ? teamKindness : null;
      final xp = rawXp is int ? rawXp : team1.scoreXp;
      final baskets = rawBaskets is int ? rawBaskets : team1.scoreBaskets;
      final coins = rawCoins ?? team1.scoreKindness;
      tB = GameMatchFinishedTeam(
        id: team1.id,
        label: team1.label,
        scoreVs: baskets,
        coins: coins,
        xp: xp,
        members: team1.members,
      );
    }

    if (wLabel == null && !isTie && wId != null) {
      if (tA?.id == wId) {
        wLabel = tA?.label;
      } else if (tB?.id == wId) {
        wLabel = tB?.label;
      }
    }

    return GameMatchFinishedEvent(
      matchId: mId,
      winnerTeamId: isTie ? null : wId,
      winnerTeamLabel: isTie ? null : wLabel,
      isTie: isTie,
      teamA: tA,
      teamB: tB,
      scores: json['scores'] is Map
          ? Map<String, dynamic>.from(json['scores'] as Map)
          : null,
      kindness: json['kindness'] is Map
          ? Map<String, dynamic>.from(json['kindness'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'matchId': matchId,
        'winnerTeamId': winnerTeamId,
        'winnerTeamLabel': winnerTeamLabel,
        'isTie': isTie,
        if (teamA != null) 'teamA': teamA!.toJson(),
        if (teamB != null) 'teamB': teamB!.toJson(),
        if (scores != null) 'scores': scores,
        if (kindness != null) 'kindness': kindness,
      };
}
