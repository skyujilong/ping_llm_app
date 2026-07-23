import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'services/ping_service.dart';
import 'services/provider_store.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const PingLlmApp());
}

class PingLlmApp extends StatelessWidget {
  const PingLlmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ProviderStore(storage: StorageService(), pingService: PingService()),
      child: MaterialApp(
        title: 'LLM Ping',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const DashboardScreen(),
      ),
    );
  }
}
