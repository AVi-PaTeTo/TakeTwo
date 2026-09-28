import '../models/search_response.dart';
import '../../../core/network/api_client.dart';

class SearchService {
  final ApiClient apiClient;

  SearchService(this.apiClient);

  Future<SearchResponse> search(String query) async {
    final response = await apiClient.dio.get(
      '/search/',
      queryParameters: {'q': query},
    );

    return SearchResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
