import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ping_llm/models/provider_model.dart';
import 'package:ping_llm/screens/dashboard_screen.dart';
import 'package:ping_llm/services/ping_service.dart';
import 'package:ping_llm/services/provider_store.dart';
import 'package:ping_llm/services/storage_service.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('dashboard renders core controls', (tester) async {
    final store = ProviderStore(
      storage: StorageService(),
      pingService: PingService(),
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: store,
        child: const MaterialApp(home: Scaffold(body: DashboardScreen())),
      ),
    );
    await tester.pump();
    expect(find.text('LLM Ping'), findsOneWidget);
    expect(find.text('一键 Ping 全部'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  testWidgets('provider defaults are available', (tester) async {
    final provider = ProviderModel(id: 'test', type: ProviderType.openai);
    expect(provider.effectiveHost, 'https://api.openai.com');
  });
}
