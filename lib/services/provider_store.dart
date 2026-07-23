import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/provider_model.dart';
import '../models/ping_result.dart';
import 'ping_service.dart';
import 'storage_service.dart';

/// Application state: manages provider list and coordinates ping operations.
class ProviderStore extends ChangeNotifier {
  ProviderStore({required this.storage, required this.pingService}) {
    initialized = _init();
  }

  final ProviderStorage storage;
  final ProviderPingService pingService;
  late final Future<void> initialized;

  List<ProviderModel> _providers = [];
  List<ProviderModel> get providers => List.unmodifiable(_providers);

  bool _pinning = false;
  bool get pinning => _pinning;

  DateTime? _lastPingAllTime;
  DateTime? get lastPingAllTime => _lastPingAllTime;

  int get onlineCount => _providers.where((p) => p.online).length;
  int get avgLatency {
    final values = _providers
        .where((p) => p.latencyMs != null)
        .map((p) => p.latencyMs!);
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) ~/ values.length;
  }

  int get monthTotalTokens =>
      _providers.fold(0, (sum, p) => sum + (p.usage?.month ?? 0));
  int get todayTotalTokens =>
      _providers.fold(0, (sum, p) => sum + (p.usage?.today ?? 0));

  Future<void> _init() async {
    _providers = await storage.loadProviders();
    notifyListeners();
  }

  Future<void> addProvider(ProviderModel provider) async {
    _providers.add(provider);
    await storage.saveProviders(_providers);
    notifyListeners();
  }

  Future<void> updateProvider(ProviderModel provider) async {
    final index = _providers.indexWhere((item) => item.id == provider.id);
    if (index < 0) {
      throw StateError('找不到服务商: ${provider.id}');
    }
    _providers[index] = provider;
    await storage.saveProviders(_providers);
    notifyListeners();
  }

  Future<void> removeProvider(String id) async {
    final exists = _providers.any((provider) => provider.id == id);
    if (!exists) throw StateError('找不到服务商: $id');
    _providers.removeWhere((provider) => provider.id == id);
    await storage.deleteProvider(id);
    await storage.saveProviders(_providers);
    notifyListeners();
  }

  Future<List<String>> fetchModels(ProviderModel provider) =>
      pingService.fetchModels(provider);

  Future<PingResult> pingSingle(
    String providerId, {
    String message = 'Reply with OK.',
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final provider = _providerById(providerId);
    final result = await pingService.ping(
      provider,
      message: message,
      timeout: timeout,
    );
    _applyResult(provider, result);
    await storage.saveProviders(_providers);
    notifyListeners();
    return result;
  }

  Future<void> pingAll({
    String message = 'Reply with OK.',
    Duration timeout = const Duration(seconds: 15),
    void Function(int done, int total)? onProgress,
  }) async {
    if (_pinning) throw StateError('批量 Ping 正在进行中');
    _pinning = true;
    _lastPingAllTime = DateTime.now();
    notifyListeners();

    try {
      for (var index = 0; index < _providers.length; index++) {
        final provider = _providers[index];
        final result = await pingService.ping(
          provider,
          message: message,
          timeout: timeout,
        );
        _applyResult(provider, result);
        onProgress?.call(index + 1, _providers.length);
      }
      await storage.saveProviders(_providers);
    } finally {
      _pinning = false;
      notifyListeners();
    }
  }

  ProviderModel _providerById(String id) {
    final index = _providers.indexWhere((provider) => provider.id == id);
    if (index < 0) throw StateError('找不到服务商: $id');
    return _providers[index];
  }

  void _applyResult(ProviderModel provider, PingResult result) {
    provider.online = result.success;
    provider.latencyMs = result.latencyMs;
    provider.lastPingAt = result.timestamp ?? DateTime.now();
    if (result.success && result.tokensUsed != null) {
      provider.usage ??= UsageStats();
      provider.usage!.today += result.tokensUsed!;
      provider.usage!.month += result.tokensUsed!;
    }
  }

  /// Explicit public refresh hook for user-triggered UI refresh.
  void refresh() => notifyListeners();

  String generateId() =>
      'p_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
}
