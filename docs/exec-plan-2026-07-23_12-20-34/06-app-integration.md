# 06-app-integration

## Goal
打通应用入口、导航、表单参数与领域服务，确保用户输入真正控制 Ping 请求。

## Depends on
- 05-provider-domain
- `lib/main.dart`
- `lib/screens/`

## Do
1. 核对 ChangeNotifierProvider 注入和初始化生命周期。
2. 让 Ping 页模型来自选中 Provider，而非硬编码列表；把消息和 timeout 传入领域服务。
3. 修复 provider 删除/编辑后选择状态和异步 mounted 安全。
4. 验证四栏导航状态保留。

## Verify
Run immediately after this step:
1. `flutter test test/widget_test.dart`。
2. `flutter analyze lib/main.dart lib/screens/`。

## Notes
- Ping 页移除不参与请求的硬编码模型下拉，改为显示选中服务商的真实 `effectiveModel`。
- 用户输入的 Ping 消息和 1–120 秒 timeout 传给 ProviderStore/PingService。
- 服务商被删除后，旧选择自动视为无效，发送按钮禁用，避免 Dropdown 断言或 `StateError`。
- 异步 Ping 完成前检查 `mounted`，避免页面销毁后 setState。
- MainShell 继续使用 IndexedStack 保留四栏状态。
- 验证：`flutter analyze` No issues found；`flutter test` 15/15 通过。
