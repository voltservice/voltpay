import 'package:riverpod/riverpod.dart';
import 'package:voltpay/features/rates/infrastructure/volt_api_client.dart';

final Provider<VoltApiClient> voltApiClientProvider = Provider<VoltApiClient>(
  (Ref ref) => VoltApiClient(),
);
