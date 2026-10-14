import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/request_model.dart';
import '../services/request_service.dart';

final requestServiceProvider = Provider<RequestService>((ref) => RequestService());

class RequestsState {
  final List<RequestModel> sent;
  final List<RequestModel> received;
  final bool isLoading;
  final String? errorMessage;

  const RequestsState({
    this.sent = const [],
    this.received = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  RequestsState copyWith({
    List<RequestModel>? sent,
    List<RequestModel>? received,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RequestsState(
      sent: sent ?? this.sent,
      received: received ?? this.received,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class RequestsNotifier extends StateNotifier<RequestsState> {
  final RequestService _service;

  RequestsNotifier(this._service) : super(const RequestsState()) {
    fetchAll();
  }

  Future<void> fetchAll() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final sentFuture = _service.getSentRequests();
      final receivedFuture = _service.getReceivedRequests();

      final results = await Future.wait([sentFuture, receivedFuture]);
      state = state.copyWith(
        sent: results[0],
        received: results[1],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<bool> approveRequest(String id, {String notes = ''}) async {
    try {
      final updated = await _service.approveRequest(id, notes: notes);
      state = state.copyWith(
        received: state.received.map((r) => r.id == id ? updated : r).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> rejectRequest(String id, {required String reason}) async {
    try {
      final updated = await _service.rejectRequest(id, reason: reason);
      state = state.copyWith(
        received: state.received.map((r) => r.id == id ? updated : r).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> cancelRequest(String id, {String reason = ''}) async {
    try {
      final updated = await _service.cancelRequest(id, reason: reason);
      state = state.copyWith(
        sent: state.sent.map((r) => r.id == id ? updated : r).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> completeRequest(String id, {String notes = ''}) async {
    try {
      final updated = await _service.completeRequest(id, notes: notes);
      state = state.copyWith(
        sent: state.sent.map((r) => r.id == id ? updated : r).toList(),
        received: state.received.map((r) => r.id == id ? updated : r).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }
}

final requestsNotifierProvider =
    StateNotifierProvider<RequestsNotifier, RequestsState>((ref) {
  return RequestsNotifier(ref.watch(requestServiceProvider));
});

final singleRequestProvider =
    FutureProvider.family<RequestModel, String>((ref, id) async {
  final service = ref.watch(requestServiceProvider);
  return await service.getRequestById(id);
});
