# MeowBiu CI/CD 配置

本文档介绍了MeowBiu应用的CI/CD配置，包括自动化测试和发布流程。

## 工作流程

本仓库包含以下GitHub Actions工作流程：

1. **Flutter测试** (`flutter_test.yml`)：
   - 在每次推送代码和创建PR时自动执行
   - 运行代码格式检查、代码分析、单元测试
   - 验证应用是否可以构建

2. **构建和发布** (`build_and_release.yml`)：
   - 在推送标签时触发（如`v1.2.8`）
   - 构建Android ARM64 APK并上传到GitHub Releases
   - 构建iOS应用并作为构建产物保存

## 发布新版本

要发布新版本，请按照以下步骤操作：

1. 更新`pubspec.yaml`文件中的版本号（例如`1.2.8+8`）
2. 提交并推送所有更改到远程仓库
3. 运行`release.bat`脚本创建标签并触发发布流程
4. 等待GitHub Actions完成构建和发布

## iOS构建注意事项

当前的iOS构建仅生成未签名的构建产物。要完成iOS应用的发布，您需要：

1. 下载GitHub Actions生成的iOS构建产物
2. 使用适当的证书和配置文件进行签名
3. 使用App Store Connect上传应用

如需完整的iOS自动化发布流程，需要配置Apple开发者证书和配置文件。

## 进一步优化

可以考虑的其他CI/CD优化：

- 添加构建缓存以加速工作流程
- 配置版本号自动递增
- 添加变更日志自动生成
- 配置自动发布到应用商店 