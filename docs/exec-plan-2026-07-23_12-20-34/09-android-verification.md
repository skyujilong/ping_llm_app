# 09-android-verification

## Goal
生成可安装 Debug APK，并在 Pixel 9 API 35 模拟器完成 Android 端到端验收。

## Depends on
- 08-tests-docs-cleanup
- Android toolchain 与 `PingLLM_Pixel9_API35` AVD

## Do
1. `flutter build apk --debug`。
2. 启动 AVD、安装并运行应用。
3. 执行最终手工流程并检查日志/崩溃。

## Verify
Run immediately after this step:
1. `build/app/outputs/flutter-apk/app-debug.apk` 存在且可安装。
2. `flutter run -d <emulator>` 启动成功。
3. 用户验收路径：打开应用 → 配置服务商 → 返回概览 → 单项/批量 Ping → 查看状态与用量；无崩溃、参数真实生效。

## Notes
- 待执行。
