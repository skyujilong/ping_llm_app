# 08-tests-docs-cleanup

## Goal
补齐关键回归测试、运行说明和代码清理，确保仓库可重复使用。

## Depends on
- 07-ui-workflows

## Do
1. 补充 UI 流程或存储边界的缺失测试。
2. 更新根 README：安装、运行、测试、APK 路径、配置说明。
3. 清理无用依赖/注释/TODO，确认 `.gitignore` 覆盖构建产物和敏感文件。

## Verify
Run immediately after this step:
1. `flutter test`。
2. `flutter analyze`。
3. README 中命令在当前环境可执行。

## Notes
- 待执行。
