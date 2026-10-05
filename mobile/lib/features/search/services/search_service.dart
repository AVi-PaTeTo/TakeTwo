import '../../../core/network/api_client.dart';
import '../models/search_response.dart';

class SearchService {
  final ApiClient apiClient;

  SearchService(this.apiClient);

  Future<SearchResponse> search(
    String query, {
    int? userPage,
    int? postPage,
  }) async {
    final queryParameters = <String, dynamic>{'q': query};

    if (userPage != null) {
      queryParameters['user_page'] = userPage;
    }

    if (postPage != null) {
      queryParameters['post_page'] = postPage;
    }

    final response = await apiClient.dio.get(
      '/search/',
      queryParameters: queryParameters,
    );

    return SearchResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
