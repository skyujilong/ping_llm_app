# LLM Ping

一款 Flutter 编写的 LLM 服务商 Token 用量调度工具。通过 Ping 触发服务商的计时起点，实时掌握各服务商的在线状态与响应延迟，从而更合理地分配单位时间内的 Token 用量，避免额度浪费与速率超限。

## 功能

- **Ping 触发计时** — 通过 Ping 发起轻量请求，标记服务商计时的起始点，为 Token 用量分配提供时间基准
- **一键 Ping 全部** — 批量检测所有已配置的 LLM 服务商，查看在线/离线状态与响应延迟
- **单个 Ping** — 对单个服务商发起快速检测，查看响应延迟
- **多服务商支持** — 内置 15+ 种 LLM 提供商预设，包括国内外主流平台
- **API Key 安全存储** — 密钥通过 `flutter_secure_storage` 加密存储，配置信息存于 `SharedPreferences`
- **模型列表拉取** — 自动从服务商 API 获取可用模型列表
- **Token 用量统计** — 基于计时起点记录每日/每月 Token 消耗，辅助合理分配单位时间用量
- **自定义接入** — 支持 OpenAI 兼容 API 和 Claude 兼容 API 的自定义接入

## 支持的服务商

| 服务商 | 默认模型 |
|---|---|
| OpenAI | gpt-4o-mini |
| Anthropic (Claude) | claude-3-haiku-20240307 |
| Google (Gemini) | gemini-2.0-flash |
| DeepSeek | deepseek-chat |
| 火山方舟 (豆包) | doubao-seed-1-6-250615 |
| 智谱AI (ChatGLM) | glm-4-flash |
| 月之暗面 (Kimi) | moonshot-v1-auto |
| MiniMax | MiniMax-M3 |
| 百川智能 | Baichuan4 |
| 阶跃星辰 | step-2-16k |
| 通义千问 (阿里) | qwen-turbo |
| 本地部署 (Ollama) | llama3 |
| 兼容 OpenAI API | 自定义 |
| 兼容 Claude API | 自定义 |

## 技术栈

- **Flutter** (Dart ^3.12.2)
- **Provider** — 状态管理
- **Dio** — HTTP 请求
- **flutter_secure_storage** — API Key 加密存储
- **shared_preferences** — 配置持久化
- **intl** — 时间格式化

## 项目结构

```
lib/
├── main.dart                      # 应用入口
├── models/
│   ├── provider_model.dart        # 服务商模型 & ProviderType 枚举
│   └── ping_result.dart           # Ping 结果模型
├── screens/
│   ├── dashboard_screen.dart      # 首页 Dashboard
│   └── providers_screen.dart      # 服务商配置页
├── services/
│   ├── ping_service.dart          # LLM Ping 请求逻辑
│   ├── provider_store.dart        # 应用状态管理
│   └── storage_service.dart       # 本地持久化
├── theme/
│   └── app_theme.dart             # Material 3 主题
└── widgets/
    ├── provider_form_sheet.dart   # 服务商添加/编辑表单
    ├── provider_tile.dart         # 服务商列表项
    └── stat_card.dart             # 统计卡片
```

## 快速开始

### 环境要求

- Flutter SDK >= 3.12.2
- Dart SDK >= 3.12.2

### 安装与运行

```bash
flutter pub get
flutter run
```

### 运行测试

```bash
flutter test
```

## Android 打包

### 环境要求

- Android Studio (或仅 Android SDK)
- JDK 17
- Flutter SDK >= 3.12.2

### Debug 构建

```bash
flutter build apk --debug
```

产物路径：`build/app/outputs/flutter-apk/app-debug.apk`

### Release 构建

当前 release 构建使用 debug 签名。如需正式发布，请先配置签名：

1. **生成签名密钥**

   ```bash
   keytool -genkey -v -keystore ~/keystore/ping-llm.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias ping-llm
   ```

2. **创建 `android/key.properties`**

   ```properties
   storePassword=<你的密码>
   keyPassword=<你的密码>
   keyAlias=ping-llm
   storeFile=/Users/<你的用户名>/keystore/ping-llm.jks
   ```

3. **修改 `android/app/build.gradle.kts` 中的签名配置**

   ```kotlin
   val keystoreProperties = Properties()
   val keystoreFile = rootProject.file("key.properties")
   if (keystoreFile.exists()) {
       keystoreProperties.load(FileInputStream(keystoreFile))
   }

   android {
       // ...

       signingConfigs {
           create("release") {
               keyAlias = keystoreProperties["keyAlias"] as String
               keyPassword = keystoreProperties["keyPassword"] as String
               storeFile = file(keystoreProperties["storeFile"] as String)
               storePassword = keystoreProperties["storePassword"] as String
           }
       }

       buildTypes {
           release {
               signingConfig = signingConfigs.getByName("release")
           }
       }
   }
   ```

4. **构建 Release APK**

   ```bash
   flutter build apk --release
   ```

   产物路径：`build/app/outputs/flutter-apk/app-release.apk`

### 分架构构建（减小体积）

```bash
flutter build apk --split-per-abi --release
```

会按 `armeabi-v7a`、`arm64-v8a`、`x86_64` 分别输出 APK。

### 直接安装到设备

```bash
# 需先通过 USB 或无线调试连接设备
flutter install
```

## 架构

应用采用分层架构，状态管理基于 Provider：

- **Models** — 纯数据类，支持 JSON 序列化/反序列化
- **Services** — 业务逻辑层，通过抽象接口解耦（`ProviderPingService`、`ProviderStorage`），便于测试 Mock
- **Screens** — UI 层，通过 `context.watch` / `context.read` 访问 `ProviderStore`
- **Widgets** — 可复用 UI 组件

## License

私有项目，未开源。
