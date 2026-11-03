import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:wings_of_power_app/app/core/config/app_config.dart';
import 'package:wings_of_power_app/app/core/services/secure_storage_service.dart';
import '../models/game_match.dart';

class GameSocketService extends GetxService {
  io.Socket? _socket;

  final isConnected = false.obs;
  final isConnecting = false.obs;
  final lastError = RxnString();

  final latestMatch = Rxn<GameMatchSnapshot>();
  final latestSnapshot = Rxn<GameMatchSnapshot>();
  final latestQueueUpdate = Rxn<GameQueueUpdate>();

  final _matchFoundController = StreamController<GameMatchSnapshot>.broadcast();
  Stream<GameMatchSnapshot> get onMatchFound => _matchFoundController.stream;

  final _snapshotController = StreamController<GameMatchSnapshot>.broadcast();
  Stream<GameMatchSnapshot> get onSnapshot => _snapshotController.stream;

  final _queueUpdateController = StreamController<GameQueueUpdate>.broadcast();
  Stream<GameQueueUpdate> get onQueueUpdate => _queueUpdateController.stream;

  io.Socket? get socket => _socket;

  static String resolveSocketUrl([String? overrideUrl]) {
    if (overrideUrl != null && overrideUrl.isNotEmpty) {
      return overrideUrl;
    }
    final domain = AppConfig.domainUrl;
    final uri = Uri.tryParse(domain);
    if (uri != null && uri.hasPort) {
      return domain;
    }
    // If domain has localhost / 127.0.0.1 / 10.0.2.2 without port, default to :3000
    if (domain.contains('localhost') ||
        domain.contains('127.0.0.1') ||
        domain.contains('10.0.2.2')) {
      return '$domain:3000';
    }
    return domain;
  }

  Future<void> connect({String? customToken, String? customUrl}) async {
    if (isConnected.value && _socket != null) {
      return;
    }

    isConnecting.value = true;
    lastError.value = null;

    final token = customToken ??
        await SecureStorageService.instance.getToken() ??
        (AppConfig.useMocks ? 'mock-student-jwt-token' : null);

    final url = resolveSocketUrl(customUrl);

    try {
      _cleanupSocket();

      final options = io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token ?? ''})
          .setExtraHeaders({'Authorization': 'Bearer ${token ?? ''}'})
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .build();

      _socket = io.io(url, options);

      _socket?.onConnect((_) {
        debugPrint('[GameSocketService] Connected to $url');
        isConnected.value = true;
        isConnecting.value = false;
        lastError.value = null;
      });

      _socket?.onDisconnect((reason) {
        debugPrint('[GameSocketService] Disconnected: $reason');
        isConnected.value = false;
        isConnecting.value = false;
      });

      _socket?.onConnectError((err) {
        debugPrint('[GameSocketService] Connect error: $err');
        isConnected.value = false;
        isConnecting.value = false;
        lastError.value = err?.toString() ?? 'Connection error';
      });

      _socket?.onError((err) {
        debugPrint('[GameSocketService] Socket error: $err');
        lastError.value = err?.toString();
      });

      _socket?.on('match:found', (data) {
        debugPrint('[GameSocketService] match:found: $data');
        if (data is Map) {
          final snapshot =
              GameMatchSnapshot.fromJson(Map<String, dynamic>.from(data));
          latestMatch.value = snapshot;
          _matchFoundController.add(snapshot);
        }
      });

      _socket?.on('match:snapshot', (data) {
        debugPrint('[GameSocketService] match:snapshot: $data');
        if (data is Map) {
          final snapshot =
              GameMatchSnapshot.fromJson(Map<String, dynamic>.from(data));
          latestSnapshot.value = snapshot;
          latestMatch.value = snapshot;
          _snapshotController.add(snapshot);
        }
      });

      _socket?.on('queue:update', (data) {
        debugPrint('[GameSocketService] queue:update: $data');
        if (data is Map) {
          final update =
              GameQueueUpdate.fromJson(Map<String, dynamic>.from(data));
          latestQueueUpdate.value = update;
          _queueUpdateController.add(update);
        }
      });

      _socket?.on('queue:error', (data) {
        debugPrint('[GameSocketService] queue:error: $data');
        if (data is Map && data['message'] != null) {
          lastError.value = data['message'].toString();
        } else {
          lastError.value = data?.toString();
        }
      });

      _socket?.on('match:error', (data) {
        debugPrint('[GameSocketService] match:error: $data');
        if (data is Map && data['message'] != null) {
          lastError.value = data['message'].toString();
        } else {
          lastError.value = data?.toString();
        }
      });

      _socket?.connect();
    } catch (e) {
      debugPrint('[GameSocketService] Exception while connecting: $e');
      isConnecting.value = false;
      lastError.value = e.toString();
    }
  }

  void joinQueue(String mode, [String? fixtureCode]) {
    _socket?.emit('queue:join', {
      'mode': mode,
      if (fixtureCode != null && fixtureCode.isNotEmpty)
        'fixtureCode': fixtureCode,
    });
  }

  void cancelQueue() {
    _socket?.emit('queue:cancel', {});
  }

  void requestSnapshot([String? matchId]) {
    _socket?.emit('match:snapshot', {
      'matchId': ?matchId,
    });
  }

  void leaveMatch(String matchId) {
    _socket?.emit('match:leave', {'matchId': matchId});
  }

  /// Simulate mock match for offline testing
  void simulateMockMatch({
    String mode = 'SINGLE',
    String? fixtureCode,
    String? currentUserId,
    String? currentUserNickname,
  }) {
    final mock = GameMatchSnapshot(
      matchId: 'practice-${DateTime.now().millisecondsSinceEpoch}',
      mode: mode,
      phase: 'COUNTDOWN',
      deadlineAt: DateTime.now().add(const Duration(seconds: 3)),
      serverNow: DateTime.now(),
      teams: [
        GameMatchTeam(
          id: 'team-single-1',
          label: 'Single Player',
          scoreXp: 0,
          scoreKindness: 0,
          scoreBaskets: 0,
          members: [
            GameMatchParticipant(
              id: 'part-you-1',
              userId: currentUserId ?? 'mock-student-id',
              nickname: currentUserNickname ?? 'Alex',
              avatarUrl: 'assets/images/avatar_01.png',
              heroId: 'faith',
              jerseyNumber: 1,
              isConnected: true,
              isBot: false,
            ),
            const GameMatchParticipant(
              id: 'part-bot-1',
              userId: null,
              nickname: 'Practice Bot',
              avatarUrl: null,
              heroId: 'harold',
              jerseyNumber: 2,
              isConnected: true,
              isBot: true,
            ),
          ],
        ),
      ],
      you: const GameMatchYou(
        participantId: 'part-you-1',
        canBuzz: false,
        powerUsed: false,
        jerseyNumber: 1,
      ),
    );
    latestMatch.value = mock;
    latestSnapshot.value = mock;
    _matchFoundController.add(mock);
  }

  void _cleanupSocket() {
    try {
      _socket?.off('connect');
      _socket?.off('disconnect');
      _socket?.off('connect_error');
      _socket?.off('error');
      _socket?.off('match:found');
      _socket?.off('match:snapshot');
      _socket?.off('queue:update');
      _socket?.off('queue:error');
      _socket?.off('match:error');
      _socket?.disconnect();
      _socket?.dispose();
    } catch (_) {}
    _socket = null;
    isConnected.value = false;
    isConnecting.value = false;
  }

  void disconnect() {
    _cleanupSocket();
  }

  @override
  void onClose() {
    disconnect();
    _matchFoundController.close();
    _snapshotController.close();
    _queueUpdateController.close();
    super.onClose();
  }
}
