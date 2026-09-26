import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/providers.dart';
import 'api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.read(secureStorageProvider));
});
