# 05-provider-domain

## Goal
验证 ProviderStore 的初始化、增删改、单项/批量 Ping、用量累计和异常状态恢复。

## Depends on
- 04-adapters-storage-http
- `lib/services/provider_store.dart`

## Do
1. 将 Ping 消息和 timeout 从 UI/领域层传给 PingService。
2. 去除单项/批量 Ping 的状态更新重复逻辑。
3. 确保批量 Ping 即使发生非预期异常也恢复 `pinning=false`。
4. 为领域逻辑补可注入存储的测试边界。

## Verify
Run immediately after this step:
1. `flutter test test/provider_store_test.dart`。
2. `flutter analyze lib/services/provider_store.dart`。

## Notes
- 抽取 `ProviderStorage` 和 `ProviderPingService` 接口，ProviderStore 依赖接口而非具体实现。
- 暴露 `initialized` Future 支持异步等待；`_applyResult` 集中化结果更新（含 `usage ??= UsageStats()`）。
- `pingAll` 使用 `try/finally` 保证 `_pinning` 在任何异常下恢复。
- `updateProvider`/`removeProvider` 缺失时抛 `StateError` 而非静默忽略。
- 新增 `test/provider_store_test.dart`：4 个测试覆盖消息/timeout 传递、批量进度、持久化失败时状态复位、缺失抛错。
- 验证：`flutter test` 15/15 通过；`flutter analyze` No issues found。
