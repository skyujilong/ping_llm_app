# 02-tooling-config

## Goal
确认 Flutter 依赖、Android 权限和本机 Android 构建工具链可用。

## Depends on
- 01-discovery-constraints
- `pubspec.yaml`
- `android/`

## Do
1. 核对 provider、dio、shared_preferences、flutter_secure_storage 等依赖。
2. 核对 Android 网络权限和本地明文端点支持。
3. 安装并配置 Android Studio JDK、SDK、平台工具、模拟器和系统镜像。

## Verify
Run immediately after this step:
1. `flutter pub get` 成功。
2. `flutter doctor -v` 的 Android toolchain 可用或仅剩许可证提示。
3. `sdkmanager --list_installed` 能看到 platform-tools、emulator、Android platform 和 ARM64 system image。

## Notes
- Android Studio 与捆绑 JDK 21 已安装。
- Android SDK 36、Build Tools 36.0.0、Platform Tools、Emulator 36.6.11、API 35 Google APIs ARM64 镜像已安装。
- Flutter 已配置 SDK/JDK，Android licenses 全部接受；`flutter doctor -v` 的 Android toolchain 为通过。
- 已创建 `PingLLM_Pixel9_API35` AVD，`flutter emulators` 可发现。
- `flutter pub get` 成功；AndroidManifest 已包含 INTERNET/ACCESS_NETWORK_STATE 与本地端点明文流量支持。
