# 04-adapters-storage-http

## Goal
核验并修复持久化适配器（SharedPreferences + FlutterSecureStorage）和 HTTP Ping 适配器（Dio）的正确性。

## Depends on
- 03-model-contracts
- `lib/services/storage_service.dart`
- `lib/services/ping_service.dart`

## Do
1. 核对 StorageService：API Key 是否从 ProviderModel JSON 中剥离、是否从安全存储还原、删除是否同步清除。
2. 核对 PingService：各 provider 端点是否正确、超时/错误处理是否无静默吞错、token 提取是否覆盖 OpenAI/Anthropic 风格。
3. 检查 `_buildRequest` 中 Google 的 API Key 是否通过 query 参数发送（而非 header）。
4. 检查 `ping()` 方法中所有 provider 的 API Key 注入是否正确。

## Verify
Run immediately after this step:
1. `flutter analyze lib/services/`。
2. 审视每处分支：无静默 fallback 到错误路径。

## Notes
- 将 OpenAI、DeepSeek、OpenAI-compatible 改为最小 `/v1/chat/completions` POST；Anthropic 使用 `/v1/messages`；Google 使用 `:generateContent`；Ollama 使用 `/api/generate`。
- 所有请求限制输出 1 token、禁用流式响应，并支持调用方传入消息和超时。
- 修正 4xx 被错误判定为成功；补充 Map/HTTP/timeout 错误归一化。
- token 提取覆盖 OpenAI、Anthropic、Google、Ollama 格式。
- StorageService 现在会在 API Key 清空时同步删除 secure storage，删除 provider 时即使 prefs 缺失也会删除 key。
- 验证：`flutter test` 11/11 通过；`flutter analyze` No issues found。