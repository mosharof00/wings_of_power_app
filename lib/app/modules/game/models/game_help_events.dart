class GameHelpRequestEvent {
  final String roundId;
  final String? fromUserId;
  final String? fromNickname;
  final String? prompt;
  final List<String> options;

  const GameHelpRequestEvent({
    required this.roundId,
    this.fromUserId,
    this.fromNickname,
    this.prompt,
    this.options = const [],
  });

  factory GameHelpRequestEvent.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List? ?? [];
    return GameHelpRequestEvent(
      roundId: json['roundId']?.toString() ?? json['round_id']?.toString() ?? '',
      fromUserId: json['fromUserId']?.toString() ??
          json['userId']?.toString() ??
          json['from_user_id']?.toString(),
      fromNickname: json['fromNickname']?.toString() ??
          json['nickname']?.toString() ??
          json['from_nickname']?.toString() ??
          'Samantha',
      prompt: json['prompt']?.toString(),
      options: rawOptions.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'roundId': roundId,
        if (fromUserId != null) 'fromUserId': fromUserId,
        if (fromNickname != null) 'fromNickname': fromNickname,
        if (prompt != null) 'prompt': prompt,
        'options': options,
      };
}

class GameHelpSuggestEvent {
  final String roundId;
  final String? forUserId;
  final String? fromUserId;
  final String? fromNickname;
  final int optionIndex;

  const GameHelpSuggestEvent({
    required this.roundId,
    this.forUserId,
    this.fromUserId,
    this.fromNickname,
    required this.optionIndex,
  });

  factory GameHelpSuggestEvent.fromJson(Map<String, dynamic> json) {
    return GameHelpSuggestEvent(
      roundId: json['roundId']?.toString() ?? json['round_id']?.toString() ?? '',
      forUserId: json['forUserId']?.toString() ??
          json['for_user_id']?.toString(),
      fromUserId: json['fromUserId']?.toString() ??
          json['from_user_id']?.toString() ??
          json['userId']?.toString(),
      fromNickname: json['fromNickname']?.toString() ??
          json['nickname']?.toString() ??
          json['from_nickname']?.toString(),
      optionIndex: (json['optionIndex'] ?? json['option_index'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'roundId': roundId,
        if (forUserId != null) 'forUserId': forUserId,
        if (fromUserId != null) 'fromUserId': fromUserId,
        if (fromNickname != null) 'fromNickname': fromNickname,
        'optionIndex': optionIndex,
      };
}
