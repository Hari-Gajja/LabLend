import '../models/equipment_model.dart';
import 'api_client.dart';

class PaginatedEquipment {
  final List<EquipmentModel> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginatedEquipment({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });
}

class EquipmentService {
  final ApiClient _apiClient;

  EquipmentService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<PaginatedEquipment> listEquipment({
    String? search,
    String? category,
    String? condition,
    String? listingType,
    String? availability,
    num? minPrice,
    num? maxPrice,
    String? city,
    String? state,
    String sort = 'newest',
    int page = 1,
    int limit = 12,
    bool? featured,
  }) async {
    final query = <String, dynamic>{
      'sort': sort,
      'page': page,
      'limit': limit,
    };

    if (search != null && search.isNotEmpty) query['search'] = search;
    if (category != null && category.isNotEmpty) query['category'] = category;
    if (condition != null && condition.isNotEmpty) query['condition'] = condition;
    if (listingType != null && listingType.isNotEmpty) query['listingType'] = listingType;
    if (availability != null && availability.isNotEmpty) query['availability'] = availability;
    if (minPrice != null) query['minPrice'] = minPrice;
    if (maxPrice != null) query['maxPrice'] = maxPrice;
    if (city != null && city.isNotEmpty) query['city'] = city;
    if (state != null && state.isNotEmpty) query['state'] = state;
    if (featured != null) query['featured'] = featured;

    final response = await _apiClient.get('/equipment', queryParameters: query);
    final data = response.data['data'];
    final pagination = response.data['pagination'] as Map<String, dynamic>?;

    final items = (data['equipment'] as List<dynamic>? ?? [])
        .map((e) => EquipmentModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedEquipment(
      items: items,
      page: pagination?['page'] ?? page,
      limit: pagination?['limit'] ?? limit,
      total: pagination?['total'] ?? items.length,
      totalPages: pagination?['totalPages'] ?? 1,
    );
  }

  Future<EquipmentModel> getEquipmentById(String id) async {
    final response = await _apiClient.get('/equipment/$id');
    return EquipmentModel.fromJson(response.data['data']['equipment']);
  }

  Future<EquipmentModel> createEquipment(Map<String, dynamic> payload) async {
    final response = await _apiClient.post('/equipment', data: payload);
    return EquipmentModel.fromJson(response.data['data']['equipment']);
  }

  Future<EquipmentModel> updateEquipment(String id, Map<String, dynamic> payload) async {
    final response = await _apiClient.patch('/equipment/$id', data: payload);
    return EquipmentModel.fromJson(response.data['data']['equipment']);
  }

  Future<void> deleteEquipment(String id) async {
    await _apiClient.delete('/equipment/$id');
  }

  Future<List<EquipmentModel>> getMyEquipment() async {
    final response = await _apiClient.get('/equipment/mine');
    final list = response.data['data']['equipment'] as List<dynamic>? ?? [];
    return list.map((e) => EquipmentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<EquipmentModel> updateAvailability(String id, String availability) async {
    final response = await _apiClient.patch(
      '/equipment/$id/availability',
      data: {'availability': availability},
    );
    return EquipmentModel.fromJson(response.data['data']['equipment']);
  }
}
