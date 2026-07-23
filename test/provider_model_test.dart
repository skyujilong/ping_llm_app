import 'package:flutter_test/flutter_test.dart';
import 'package:ping_llm/models/provider_model.dart';

void main() {
  group('ProviderModel', () {
    test('uses provider defaults when fields are empty', () {
      final p = ProviderModel(id: '1', type: ProviderType.openai);
      expect(p.effectiveName, 'OpenAI');
      expect(p.effectiveHost, 'https://api.openai.com');
      expect(p.effectiveModel, 'gpt-4o-mini');
    });

    test('initializes usage tracking for new providers', () {
      final p = ProviderModel(id: '1', type: ProviderType.openai);

      expect(p.usage, isNotNull);
      expect(p.usage?.today, 0);
      expect(p.usage?.month, 0);
      expect(p.usage?.quota, 200000);
    });

    test('round-trips through JSON', () {
      final p = ProviderModel(
        id: 'p1',
        type: ProviderType.anthropic,
        displayName: 'Claude',
        host: 'https://api.anthropic.com',
        model: 'claude-opus-4-8',
        online: true,
        latencyMs: 320,
        usage: UsageStats(today: 10, month: 100, quota: 1000),
      );
      final decoded = ProviderModel.fromJson(p.toJson());
      expect(decoded.id, p.id);
      expect(decoded.type, ProviderType.anthropic);
      expect(decoded.online, isTrue);
      expect(decoded.usage?.month, 100);
    });
  });
}
