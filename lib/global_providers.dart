import 'package:bbs_driver/features/auth/presentation/providers/auth_provider.dart';
// import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

List<Provider> getAppProviders() {
  return [Provider(create: (context) => AuthProvider())];
}
