import 'dart:async';
import 'package:dio/dio.dart';
import '../models/provider_model.dart';
import '../models/ping_result.dart';

/// Provider ping boundary used by application state.
abstract interface class ProviderPingService {
  Future<PingResult> ping(
    ProviderModel provider, {
    String message = 'Reply with OK.',
    Duration timeout = const Duration(seconds: 15),
  });

  /// Fetch available model IDs from the provider's API.
  Future<List<String>> fetchModels(
    ProviderModel provider, {
    Duration timeout = const Duration(seconds: 10),
  });
}

/// Sends a minimal, non-streaming generation request to verify the model itself.
class PingService implements ProviderPingService {
  PingService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ),
          );

  final Dio _dio;

  @override
  Future<PingResult> ping(
    ProviderModel provider, {
    String message = 'Reply with OK.',
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final timestamp = DateTime.now();
    if (message.trim().isEmpty) {
      return PingResult(
        providerId: provider.id,
        success: false,
        timestamp: timestamp,
        errorMessage: 'Ping 消息不能为空',
      );
    }

    final stopwatch = Stopwatch()..start();
    final cancelToken = CancelToken();
    try {
      final headers = _buildHeaders(provider);
      final (uri, body) = _buildRequest(provider, message.trim());
      final response = await _dio
          .post<dynamic>(
            uri.toString(),
            data: body,
            options: Options(
              headers: headers,
              sendTimeout: timeout,
              receiveTimeout: timeout,
            ),
            cancelToken: cancelToken,
          )
          .timeout(
            timeout,
            onTimeout: () {
              cancelToken.cancel('Ping 请求超时');
              throw TimeoutException('Ping 请求超时');
            },
          );
      stopwatch.stop();

      final bodyText = response.data?.toString() ?? '';
      return PingResult(
        providerId: provider.id,
        success:
            response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300,
        latencyMs: stopwatch.elapsedMilliseconds,
        timestamp: timestamp,
        responseBody: bodyText.length > 2000
            ? '${bodyText.substring(0, 2000)}…'
            : bodyText,
        tokensUsed: _extractTokens(response.data),
      );
    } catch (error) {
      stopwatch.stop();
      return PingResult(
        providerId: provider.id,
        success: false,
        latencyMs: stopwatch.elapsedMilliseconds,
        timestamp: timestamp,
        errorMessage: _normalizeError(error),
      );
    }
  }

  Map<String, dynamic> _buildHeaders(ProviderModel provider) {
    final headers = <String, dynamic>{'Content-Type': 'application/json'};
    if (provider.apiKey.isEmpty) return headers;

    switch (provider.type) {
      case ProviderType.anthropic:
      case ProviderType.anthropicCompat:
        headers['x-api-key'] = provider.apiKey;
        headers['anthropic-version'] = '2023-06-01';
      case ProviderType.google:
      case ProviderType.local:
        break;
      case ProviderType.openai:
      case ProviderType.deepseek:
      case ProviderType.volcengine:
      case ProviderType.zhipu:
      case ProviderType.moonshot:
      case ProviderType.minimax:
      case ProviderType.baichuan:
      case ProviderType.stepfun:
      case ProviderType.qwen:
      case ProviderType.openaiCompat:
        headers['Authorization'] = 'Bearer ${provider.apiKey}';
    }
    return headers;
  }

  /// Maps a provider to its smallest supported generation request.
  (Uri, Map<String, dynamic>) _buildRequest(
    ProviderModel provider,
    String message,
  ) {
    final host = provider.effectiveHost.replaceFirst(RegExp(r'/+$'), '');
    switch (provider.type) {
      case ProviderType.anthropic:
      case ProviderType.anthropicCompat:
        return (
          Uri.parse('$host/v1/messages'),
          {
            'model': provider.effectiveModel,
            'max_tokens': 1,
            'messages': [
              {'role': 'user', 'content': message},
            ],
          },
        );
      case ProviderType.google:
        return (
          Uri.parse(
            '$host/v1beta/models/${Uri.encodeComponent(provider.effectiveModel)}:generateContent',
          ).replace(
            queryParameters: {
              if (provider.apiKey.isNotEmpty) 'key': provider.apiKey,
            },
          ),
          {
            'contents': [
              {
                'parts': [
                  {'text': message},
                ],
              },
            ],
            'generationConfig': {'maxOutputTokens': 1},
          },
        );
      case ProviderType.local:
        return (
          Uri.parse('$host/api/generate'),
          {
            'model': provider.effectiveModel,
            'prompt': message,
            'stream': false,
            'options': {'num_predict': 1},
          },
        );
      case ProviderType.openai:
      case ProviderType.deepseek:
      case ProviderType.moonshot:
      case ProviderType.minimax:
      case ProviderType.baichuan:
      case ProviderType.stepfun:
      case ProviderType.qwen:
      case ProviderType.openaiCompat:
        return (
          Uri.parse('$host/v1/chat/completions'),
          {
            'model': provider.effectiveModel,
            'max_tokens': 1,
            'stream': false,
            'messages': [
              {'role': 'user', 'content': message},
            ],
          },
        );
      case ProviderType.volcengine:
      case ProviderType.zhipu:
        return (
          Uri.parse('$host/chat/completions'),
          {
            'model': provider.effectiveModel,
            'max_tokens': 1,
            'stream': false,
            'messages': [
              {'role': 'user', 'content': message},
            ],
          },
        );
    }
  }

  int? _extractTokens(dynamic data) {
    if (data is! Map) return null;

    final usage = data['usage'];
    if (usage is Map) {
      final total = _asInt(usage['total_tokens']);
      if (total != null) return total;

      final input = _asInt(usage['input_tokens']);
      final output = _asInt(usage['output_tokens']);
      if (input != null || output != null) return (input ?? 0) + (output ?? 0);
    }

    final googleUsage = data['usageMetadata'];
    if (googleUsage is Map) {
      final total = _asInt(googleUsage['totalTokenCount']);
      if (total != null) return total;
    }

    final prompt = _asInt(data['prompt_eval_count']);
    final generated = _asInt(data['eval_count']);
    if (prompt != null || generated != null) {
      return (prompt ?? 0) + (generated ?? 0);
    }
    return null;
  }

  int? _asInt(dynamic value) => value is num ? value.toInt() : null;

  String _normalizeError(dynamic error) {
    if (error is TimeoutException) return error.message ?? 'Ping 请求超时';
    if (error is DioException) {
      final response = error.response;
      if (response?.data is Map) {
        final body = response!.data as Map;
        final apiError = body['error'];
        if (apiError is Map && apiError['message'] != null) {
          return apiError['message'].toString();
        }
        if (apiError != null) return apiError.toString();
      }
      if (response?.statusCode != null) {
        final reason = response?.statusMessage;
        return 'HTTP ${response!.statusCode}${reason == null || reason.isEmpty ? '' : ': $reason'}';
      }
      return error.message ?? '请求失败';
    }
    return error.toString();
  }

  @override
  Future<List<String>> fetchModels(
    ProviderModel provider, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final host = provider.effectiveHost.replaceFirst(RegExp(r'/+$'), '');
    final headers = _buildHeaders(provider);
    final (uri, key) = _buildModelsRequest(provider, host);

    try {
      final response = await _dio.get<dynamic>(
        uri.toString(),
        options: Options(
          headers: headers,
          sendTimeout: timeout,
          receiveTimeout: timeout,
        ),
      );
      return _parseModelList(response.data, provider.type)..sort();
    } on DioException catch (e) {
      throw Exception(_normalizeError(e));
    }
  }

  (Uri, String?) _buildModelsRequest(ProviderModel provider, String host) {
    switch (provider.type) {
      case ProviderType.anthropic:
      case ProviderType.anthropicCompat:
        return (Uri.parse('$host/v1/models'), null);
      case ProviderType.google:
        return (
          Uri.parse('$host/v1beta/models').replace(
            queryParameters: {
              if (provider.apiKey.isNotEmpty) 'key': provider.apiKey,
            },
          ),
          null,
        );
      case ProviderType.local:
        return (Uri.parse('$host/api/tags'), null);
      case ProviderType.openai:
      case ProviderType.deepseek:
      case ProviderType.moonshot:
      case ProviderType.minimax:
      case ProviderType.baichuan:
      case ProviderType.stepfun:
      case ProviderType.qwen:
      case ProviderType.openaiCompat:
        return (Uri.parse('$host/v1/models'), null);
      case ProviderType.volcengine:
      case ProviderType.zhipu:
        return (Uri.parse('$host/models'), null);
    }
  }

  List<String> _parseModelList(dynamic data, ProviderType type) {
    if (data is! Map) return [];
    switch (type) {
      case ProviderType.google:
        final models = data['models'];
        if (models is! List) return [];
        return models
            .whereType<Map>()
            .map((m) {
              final name = m['name'] as String?;
              if (name == null) return null;
              // strip "models/" prefix from "models/gemini-2.0-flash"
              return name.replaceFirst(RegExp(r'^models/'), '');
            })
            .whereType<String>()
            .toList();
      case ProviderType.local:
        final models = data['models'];
        if (models is! List) return [];
        return models
            .whereType<Map>()
            .map((m) => m['name'] as String?)
            .whereType<String>()
            .toList();
      case ProviderType.openai:
      case ProviderType.anthropic:
      case ProviderType.anthropicCompat:
      case ProviderType.deepseek:
      case ProviderType.volcengine:
      case ProviderType.zhipu:
      case ProviderType.moonshot:
      case ProviderType.minimax:
      case ProviderType.baichuan:
      case ProviderType.stepfun:
      case ProviderType.qwen:
      case ProviderType.openaiCompat:
        final list = data['data'];
        if (list is! List) return [];
        return list
            .whereType<Map>()
            .map((m) => m['id'] as String?)
            .whereType<String>()
            .toList();
    }
  }
}
