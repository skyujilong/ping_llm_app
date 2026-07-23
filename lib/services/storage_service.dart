import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/provider_model.dart';

/// Persistence boundary used by application state.
abstract interface class ProviderStorage {
  Future<List<ProviderModel>> loadProviders();
  Future<void> saveProviders(List<ProviderModel> providers);
  Future<void> deleteProvider(String id);
}

/// Manages persistence: API keys in secure storage, config in SharedPreferences.
class StorageService implements ProviderStorage {
  StorageService() : _secure = const FlutterSecureStorage();

  final FlutterSecureStorage _secure;
  static const _providersKey = 'providers_v2';
  static const _keysPrefix = 'api_key_';

  // ---------------------------------------------------------------------------
  // Provider config (non-secret) — SharedPreferences
  // ---------------------------------------------------------------------------
  @override
  Future<List<ProviderModel>> loadProviders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_providersKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    final providers = list
        .map((e) => ProviderModel.fromJson(e as Map<String, dynamic>))
        .toList();
    // hydrate API keys from secure storage
    for (final p in providers) {
      p.apiKey = (await _secure.read(key: _keyFor(p.id))) ?? '';
    }
    return providers;
  }

  @override
  Future<void> saveProviders(List<ProviderModel> providers) async {
    // strip keys before writing to SharedPreferences
    final stripped = providers.map((p) {
      final json = p.toJson();
      json['apiKey'] = ''; // never stored in prefs
      return json;
    }).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_providersKey, jsonEncode(stripped));
    // Keep secure storage in sync, including explicit key removal.
    for (final p in providers) {
      if (p.apiKey.isEmpty) {
        await _secure.delete(key: _keyFor(p.id));
      } else {
        await _secure.write(key: _keyFor(p.id), value: p.apiKey);
      }
    }
  }

  @override
  Future<void> deleteProvider(String id) async {
    await _secure.delete(key: _keyFor(id));
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_providersKey);
    if (raw == null) return;
    final list = (jsonDecode(raw) as List<dynamic>)
        .where((e) => (e as Map)['id'] != id)
        .toList();
    await prefs.setString(_providersKey, jsonEncode(list));
  }

  String _keyFor(String id) => '$_keysPrefix$id';
}
