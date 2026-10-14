import '../models/request_model.dart';
import 'api_client.dart';

class RequestService {
  final ApiClient _apiClient;

  RequestService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<RequestModel> createRequest({
    required String equipmentId,
    required String requestType,
    int requestedQuantity = 1,
    DateTime? rentalStartDate,
    DateTime? rentalEndDate,
    required String intendedUse,
    String message = '',
  }) async {
    final payload = <String, dynamic>{
      'equipmentId': equipmentId,
      'requestType': requestType,
      'requestedQuantity': requestedQuantity,
      'intendedUse': intendedUse,
      'message': message,
    };

    if (rentalStartDate != null) {
      payload['rentalStartDate'] = rentalStartDate.toIso8601String();
    }
    if (rentalEndDate != null) {
      payload['rentalEndDate'] = rentalEndDate.toIso8601String();
    }

    final response = await _apiClient.post('/requests', data: payload);
    return RequestModel.fromJson(response.data['data']['request']);
  }

  Future<List<RequestModel>> getSentRequests() async {
    final response = await _apiClient.get('/requests/sent');
    final list = response.data['data']['requests'] as List<dynamic>? ?? [];
    return list.map((r) => RequestModel.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<List<RequestModel>> getReceivedRequests() async {
    final response = await _apiClient.get('/requests/received');
    final list = response.data['data']['requests'] as List<dynamic>? ?? [];
    return list.map((r) => RequestModel.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<RequestModel> getRequestById(String id) async {
    final response = await _apiClient.get('/requests/$id');
    return RequestModel.fromJson(response.data['data']['request']);
  }

  Future<RequestModel> approveRequest(String id, {String notes = ''}) async {
    final response = await _apiClient.patch(
      '/requests/$id/approve',
      data: {'notes': notes},
    );
    return RequestModel.fromJson(response.data['data']['request']);
  }

  Future<RequestModel> rejectRequest(String id, {required String reason}) async {
    final response = await _apiClient.patch(
      '/requests/$id/reject',
      data: {'reason': reason},
    );
    return RequestModel.fromJson(response.data['data']['request']);
  }

  Future<RequestModel> cancelRequest(String id, {String reason = ''}) async {
    final response = await _apiClient.patch(
      '/requests/$id/cancel',
      data: {'reason': reason},
    );
    return RequestModel.fromJson(response.data['data']['request']);
  }

  Future<RequestModel> completeRequest(String id, {String notes = ''}) async {
    final response = await _apiClient.patch(
      '/requests/$id/complete',
      data: {'notes': notes},
    );
    return RequestModel.fromJson(response.data['data']['request']);
  }
}
