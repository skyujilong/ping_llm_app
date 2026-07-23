# 01-discovery-constraints

## Goal
确认 Open Design 原型、用户边界和 Flutter Android 目标，形成可核验的实现范围。

## Depends on
- `original-plan.md`
- Open Design 项目目录

## Do
1. 核对原型文件、页面结构、视觉令牌和交互入口。
2. 固化 Android 优先、仅手动 Ping、可自定义服务地址等边界。
3. 对照当前 Flutter 目录确认架构分层覆盖需求。

## Verify
Run immediately after this step:
1. 原型目录关键文件可读，需求与 `split-audit.md` 一一映射。
2. `flutter analyze` 能识别当前 Flutter 工程。

## Notes
- Open Design 源目录包含 `llm-ping-monitor.html` 与 artifact 元数据；已核对指标卡、服务商状态、表单、用量条及四栏导航。
- 当前 Flutter 工程按 models/services/widgets/screens/theme 分层，覆盖 Android 优先、仅手动 Ping、自定义服务地址边界。
- 验证：`flutter analyze` → No issues found。
