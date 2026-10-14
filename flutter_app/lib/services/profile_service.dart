import '../models/institution_model.dart';
import 'api_client.dart';

class ProfileService {
  final ApiClient _apiClient;

  ProfileService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<InstitutionModel> getMyInstitution() async {
    final response = await _apiClient.get('/institutions/me');
    return InstitutionModel.fromJson(response.data['data']['institution']);
  }

  Future<InstitutionModel> updateMyInstitution(Map<String, dynamic> data) async {
    final response = await _apiClient.patch('/institutions/me', data: data);
    return InstitutionModel.fromJson(response.data['data']['institution']);
  }

  Future<InstitutionModel> getInstitutionById(String id) async {
    final response = await _apiClient.get('/institutions/$id');
    return InstitutionModel.fromJson(response.data['data']['institution']);
  }
}
