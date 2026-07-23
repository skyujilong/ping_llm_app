# 03-model-contracts

## Goal
验证服务商配置、用量统计和 Ping 结果类型能稳定承载持久化与 UI。

## Depends on
- 02-tooling-config
- `lib/models/provider_model.dart`
- `lib/models/ping_result.dart`

## Do
1. 核对 ProviderType 默认地址、模型、图标与颜色。
2. 核对 ProviderModel/UsageStats JSON 往返和默认值行为。
3. 核对 PingResult 对成功、错误、延迟、响应与 token 的表达。

## Verify
Run immediately after this step:
1. `flutter test test/provider_model_test.dart`。
2. `flutter analyze lib/models test/provider_model_test.dart`。

## Notes
- 核验时发现新建 Provider 的 `usage` 为 null，成功 Ping 无法累计 token；在本步骤修正为默认 `UsageStats()` 并补回归测试。
- 待运行本步骤验证命令。
