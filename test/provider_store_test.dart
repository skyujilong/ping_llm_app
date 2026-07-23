import 'package:flutter_test/flutter_test.dart';
import 'package:ping_llm/models/ping_result.dart';
import 'package:ping_llm/models/provider_model.dart';
import 'package:ping_llm/services/ping_service.dart';
import 'package:ping_llm/services/provider_store.dart';
import 'package:ping_llm/services/storage_service.dart';

void main() {
  group('ProviderStore', () {
    test('passes user ping options and accumulates successful usage', () async {
      final provider = ProviderModel(id: 'p1', type: ProviderType.openai);
      final storage = _MemoryStorage([provider]);
      final pinger = _FakePingService(
        PingResult(
          providerId: 'p1',
          success: true,
          latencyMs: 42,
          timestamp: DateTime(2026, 7, 23),
          tokensUsed: 5,
        ),
      );
      final store = ProviderStore(storage: storage, pingService: pinger);
      await store.initialized;

      final result = await store.pingSingle(
        'p1',
        message: 'custom ping',
        timeout: const Duration(seconds: 7),
      );

      expect(result.success, isTrue);
      expect(pinger.lastMessage, 'custom ping');
      expect(pinger.lastTimeout, const Duration(seconds: 7));
      expect(store.providers.single.online, isTrue);
      expect(store.providers.single.latencyMs, 42);
      expect(store.todayTotalTokens, 5);
      expect(store.monthTotalTokens, 5);
      expect(storage.saveCount, 1);
    });

    test('batch ping reports progress and always resets pinning', () async {
      final providers = [
        ProviderModel(id: 'p1', type: ProviderType.openai),
        ProviderModel(id: 'p2', type: ProviderType.anthropic),
      ];
      final storage = _MemoryStorage(providers);
      final pinger = _FakePingService(
        PingResult(providerId: '', success: true, tokensUsed: 1),
      );
      final store = ProviderStore(storage: storage, pingService: pinger);
      await store.initialized;
      final progress = <int>[];

      await store.pingAll(onProgress: (done, _) => progress.add(done));

      expect(progress, [1, 2]);
      expect(store.pinning, isFalse);
      expect(store.onlineCount, 2);
      expect(store.todayTotalTokens, 2);
    });

    test('batch ping resets pinning when persistence fails', () async {
      final storage = _MemoryStorage([
        ProviderModel(id: 'p1', type: ProviderType.openai),
      ])..failOnSave = true;
      final store = ProviderStore(
        storage: storage,
        pingService: _FakePingService(
          PingResult(providerId: 'p1', success: true),
        ),
      );
      await store.initialized;

      await expectLater(store.pingAll(), throwsStateError);

      expect(store.pinning, isFalse);
    });

    test('editing or removing an unknown provider fails loudly', () async {
      final storage = _MemoryStorage([]);
      final store = ProviderStore(
        storage: storage,
        pingService: _FakePingService(
          PingResult(providerId: '', success: true),
        ),
      );
      await store.initialized;
      final unknown = ProviderModel(id: 'missing', type: ProviderType.openai);

      await expectLater(store.updateProvider(unknown), throwsStateError);
      await expectLater(store.removeProvider('missing'), throwsStateError);
    });
  });
}

class _MemoryStorage implements ProviderStorage {
  _MemoryStorage(List<ProviderModel> providers) : stored = [...providers];

  List<ProviderModel> stored;
  int saveCount = 0;
  bool failOnSave = false;

  @override
  Future<List<ProviderModel>> loadProviders() async => [...stored];

  @override
  Future<void> saveProviders(List<ProviderModel> providers) async {
    if (failOnSave) throw StateError('save failed');
    saveCount++;
    stored = [...providers];
  }

  @override
  Future<void> deleteProvider(String id) async {
    stored.removeWhere((provider) => provider.id == id);
  }
}

class _FakePingService implements ProviderPingService {
  _FakePingService(this.result);

  final PingResult result;
  String? lastMessage;
  Duration? lastTimeout;

  @override
  Future<PingResult> ping(
    ProviderModel provider, {
    String message = 'Reply with OK.',
    Duration timeout = const Duration(seconds: 15),
  }) async {
    lastMessage = message;
    lastTimeout = timeout;
    return PingResult(
      providerId: provider.id,
      success: result.success,
      latencyMs: result.latencyMs,
      timestamp: result.timestamp,
      errorMessage: result.errorMessage,
      responseBody: result.responseBody,
      tokensUsed: result.tokensUsed,
    );
  }

  @override
  Future<List<String>> fetchModels(
    ProviderModel provider, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    return ['gpt-4o-mini', 'gpt-4o', 'gpt-4-turbo'];
  }
}
