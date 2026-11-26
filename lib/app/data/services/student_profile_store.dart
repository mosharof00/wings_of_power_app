import 'package:get/get.dart';

import '../models/user_models/student_profile_model.dart';
import '../repositories/profile_repository.dart';

/// The current student's saved profile, shared across the signed-in screens.
class StudentProfileStore {
  StudentProfileStore(this._repository);

  final IProfileRepository _repository;
  final profile = Rxn<StudentProfileModel>();
  final isLoading = false.obs;
  final loadFailed = false.obs;

  Future<void>? _refreshRequest;
  Future<void>? _updateRequest;
  int _session = 0;
  int _revision = 0;

  Future<void> refresh() {
    return _refreshRequest ??= _refresh(_session, _revision);
  }

  Future<void> _refresh(int session, int revision) async {
    isLoading.value = true;
    try {
      final result = await _repository.getProfile();
      if (session == _session && revision == _revision) {
        profile.value = result;
        loadFailed.value = false;
      }
    } catch (_) {
      if (session == _session && revision == _revision) {
        loadFailed.value = true;
      }
    } finally {
      if (session == _session) {
        _refreshRequest = null;
        isLoading.value = false;
      }
    }
  }

  Future<void> update({String? nickname, String? avatarUrl}) {
    final session = _session;
    final previous = _updateRequest ?? Future<void>.value();
    final request = previous.catchError((Object _) {}).then((_) async {
      if (session != _session) return;
      final updated = await _repository.updateProfile(
        nickname: nickname,
        avatarUrl: avatarUrl,
      );
      if (session != _session) return;

      _revision++;
      profile.value = updated;
      loadFailed.value = false;
    });
    _updateRequest = request;
    return request.whenComplete(() {
      if (identical(_updateRequest, request)) _updateRequest = null;
    });
  }

  void reset() {
    _session++;
    _updateRequest = null;
    _refreshRequest = null;
    profile.value = null;
    isLoading.value = false;
    loadFailed.value = false;
  }
}
