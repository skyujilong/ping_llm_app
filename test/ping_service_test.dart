import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ping_llm/models/provider_model.dart';
import 'package:ping_llm/services/ping_service.dart';

void main() {
  group('PingService request contracts', () {
    test('OpenAI sends a minimal chat completion request', () async {
      final adapter = _RecordingAdapter({
        'usage': {'total_tokens': 3},
      });
      final service = PingService(dio: Dio()..httpClientAdapter = adapter);
      final provider = ProviderModel(
        id: 'openai',
        type: ProviderType.openai,
        apiKey: 'secret',
      );

      final result = await service.ping(provider, message: 'ok');

      expect(result.success, isTrue);
      expect(result.tokensUsed, 3);
      expect(adapter.request.method, 'POST');
      expect(adapter.request.uri.path, '/v1/chat/completions');
      expect(adapter.request.headers['Authorization'], 'Bearer secret');
      expect(adapter.request.data['model'], 'gpt-4o-mini');
      expect(adapter.request.data['max_tokens'], 1);
    });

    test('Anthropic uses Messages API and Anthropic headers', () async {
      final adapter = _RecordingAdapter({
        'usage': {'input_tokens': 4, 'output_tokens': 1},
      });
      final service = PingService(dio: Dio()..httpClientAdapter = adapter);
      final provider = ProviderModel(
        id: 'anthropic',
        type: ProviderType.anthropic,
        apiKey: 'secret',
      );

      final result = await service.ping(provider);

      expect(result.tokensUsed, 5);
      expect(adapter.request.uri.path, '/v1/messages');
      expect(adapter.request.headers['x-api-key'], 'secret');
      expect(adapter.request.headers['anthropic-version'], '2023-06-01');
      expect(adapter.request.headers.containsKey('Authorization'), isFalse);
    });

    test('Google uses generateContent with query key', () async {
      final adapter = _RecordingAdapter({
        'usageMetadata': {'totalTokenCount': 2},
      });
      final service = PingService(dio: Dio()..httpClientAdapter = adapter);
      final provider = ProviderModel(
        id: 'google',
        type: ProviderType.google,
        apiKey: 'google-key',
      );

      final result = await service.ping(provider);

      expect(result.tokensUsed, 2);
      expect(
        adapter.request.uri.path,
        '/v1beta/models/gemini-2.0-flash:generateContent',
      );
      expect(adapter.request.uri.queryParameters['key'], 'google-key');
      expect(adapter.request.headers.containsKey('Authorization'), isFalse);
    });

    test('Ollama uses non-streaming generate endpoint', () async {
      final adapter = _RecordingAdapter({
        'prompt_eval_count': 2,
        'eval_count': 1,
      });
      final service = PingService(dio: Dio()..httpClientAdapter = adapter);
      final provider = ProviderModel(id: 'local', type: ProviderType.local);

      final result = await service.ping(provider);

      expect(result.tokensUsed, 3);
      expect(adapter.request.uri.path, '/api/generate');
      expect(adapter.request.data['stream'], isFalse);
      expect(adapter.request.data['options']['num_predict'], 1);
    });

    test('HTTP 4xx is reported as a failed ping', () async {
      final adapter = _RecordingAdapter(
        {
          'error': {'message': 'invalid key'},
        },
        statusCode: 401,
      );
      final dio = Dio(
        BaseOptions(validateStatus: (_) => true),
      )..httpClientAdapter = adapter;
      final service = PingService(dio: dio);
      final provider = ProviderModel(id: 'bad', type: ProviderType.openai);

      final result = await service.ping(provider);

      expect(result.success, isFalse);
      expect(result.latencyMs, isNotNull);
    });

    test('blank ping messages fail before network I/O', () async {
      final adapter = _RecordingAdapter({});
      final service = PingService(dio: Dio()..httpClientAdapter = adapter);
      final provider = ProviderModel(id: 'blank', type: ProviderType.openai);

      final result = await service.ping(provider, message: '  ');

      expect(result.success, isFalse);
      expect(result.errorMessage, 'Ping 消息不能为空');
      expect(adapter.wasCalled, isFalse);
    });
  });
}

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.responseData, {this.statusCode = 200});

  final Object responseData;
  final int statusCode;
  late RequestOptions request;
  bool wasCalled = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    wasCalled = true;
    request = options;
    return ResponseBody.fromString(
      jsonEncode(responseData),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
