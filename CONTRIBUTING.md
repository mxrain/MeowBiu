# 贡献指南

感谢你对喵王语录项目的关注！欢迎提交 Issue 和 Pull Request。

## 开发环境

- Flutter 3.24.0+
- Dart 3.8.1+
- Android Studio / VS Code

## 开始开发

```bash
# 克隆项目
git clone https://github.com/mxrain/miaowang.git
cd miaowang

# 安装依赖
flutter pub get

# 生成 Hive 适配器
flutter pub run build_runner build

# 运行项目
flutter run
```

## 提交规范

请使用 [Conventional Commits](https://www.conventionalcommits.org/zh-hans/) 规范：

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type 类型

- `feat`: 新功能
- `fix`: 修复 Bug
- `docs`: 文档更新
- `style`: 代码格式（不影响功能）
- `refactor`: 重构
- `perf`: 性能优化
- `test`: 测试相关
- `chore`: 构建/工具相关

### 示例

```
feat(audio): 添加音频播放进度条

- 显示当前播放进度
- 支持拖动调整播放位置

Closes #123
```

## Pull Request 流程

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feat/amazing-feature`)
3. 提交更改 (`git commit -m 'feat: add amazing feature'`)
4. 推送到分支 (`git push origin feat/amazing-feature`)
5. 创建 Pull Request

## 代码规范

- 遵循 [Effective Dart](https://dart.dev/guides/language/effective-dart) 规范
- 运行 `flutter analyze` 确保无警告
- 新功能需要添加相应测试

## Issue 反馈

提交 Issue 时请包含：

- 问题描述
- 复现步骤
- 期望行为
- 实际行为
- 环境信息（系统、Flutter 版本等）
- 截图（如适用）
