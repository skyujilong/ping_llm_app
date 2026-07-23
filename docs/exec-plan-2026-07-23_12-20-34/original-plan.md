请基于这个 Open Design 项目的本地文件夹继续实现：

```
/Users/nbe01/Library/Application Support/Open Design/namespaces/release-stable/data/projects/c8653d2d-7242-4a8a-8968-e4473c455ffb
```

目标: React
CLI: Claude Code (claude)

你现在是在 Claude Code 中接手，请：
1. 先进入或读取这个目录，优先阅读 DESIGN.md、README、现有 HTML/CSS/JS、素材和 package.json（如果存在）。
2. 保持现有视觉、布局、交互和素材，不要只描述方案。
3. 生成真实可运行的flutter代码。 注意要先从架构思维设置好架构后，在去分块进行开发代码
4. 完成后告诉我运行、预览和验证命令。

如果要先切到项目目录，可以用：

```bash
cd '/Users/nbe01/Library/Application Support/Open Design/namespaces/release-stable/data/projects/c8653d2d-7242-4a8a-8968-e4473c455ffb'
```

项目: LLM 用量监控 App
项目 ID: c8653d2d-7242-4a8a-8968-e4473c455ffb

补充说明 ，核心功能就是 ping 一下 llm 让模型厂商可以重新开始计时。 还有 能够自己配置模型地址等。

后续确认的实现边界：
- 使用 Flutter 实现，先主要完成 Android 端。
- 允许安装 Android 配套开发工具。
- 当前版本只做手动 Ping，不做后台定时 Ping。
- 配置与 API Key 需要持久化，API Key 使用安全存储。
- 保留原型的概览指标、服务商状态、用量进度和四栏导航视觉。
