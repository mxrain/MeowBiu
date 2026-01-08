# 喵王语录 (MeowBiu)

<p align="center">
  <img src="assets/images/logo.png" alt="喵王语录" width="120">
</p>

<p align="center">
  <a href="https://github.com/mxrain/miaowang/releases/latest">
    <img src="https://img.shields.io/github/v/release/mxrain/miaowang?style=flat-square" alt="Release">
  </a>
  <a href="https://github.com/mxrain/miaowang/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/mxrain/miaowang?style=flat-square" alt="License">
  </a>
  <a href="https://github.com/mxrain/miaowang/stargazers">
    <img src="https://img.shields.io/github/stars/mxrain/miaowang?style=flat-square" alt="Stars">
  </a>
</p>

<p align="center">
  一款可爱的猫猫语录应用，收集和播放各种猫叫声 🐱
</p>

## ✨ 功能特性

- 🎵 支持本地和网络音频
- 📁 自定义分类管理
- 💾 音频自动缓存，支持离线播放
- 🎨 Material 3 设计风格
- 🔄 应用内自动更新检测
- 📱 多平台支持

## 📥 下载安装

| 平台 | 下载 |
|------|------|
| Android | [APK](https://github.com/mxrain/miaowang/releases/latest/download/app-release.apk) |
| Windows | [EXE](https://github.com/mxrain/miaowang/releases/latest/download/miaowang-windows-setup.exe) |
| macOS | [DMG](https://github.com/mxrain/miaowang/releases/latest) |
| Linux | [tar.gz](https://github.com/mxrain/miaowang/releases/latest/download/linux-release.tar.gz) |
| iOS | [IPA](https://github.com/mxrain/miaowang/releases/latest) (需自签名) |

或访问 [Releases](https://github.com/mxrain/miaowang/releases) 页面下载所有版本。

## 🚀 快速开始

### 从源码构建

```bash
# 克隆项目
git clone https://github.com/mxrain/miaowang.git
cd miaowang

# 安装依赖
flutter pub get

# 生成代码
flutter pub run build_runner build

# 运行
flutter run
```

### 构建发布版本

```bash
# Android
flutter build apk --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## 📖 使用说明

1. **添加分类** - 点击 Tab 栏右侧的 `+` 按钮
2. **添加猫声** - 在分类页面点击右下角的 `+` 按钮
3. **播放** - 点击猫声按钮即可播放
4. **管理** - 长按猫声或分类可编辑/删除

## 🛠️ 技术栈

- [Flutter](https://flutter.dev/) - 跨平台 UI 框架
- [Riverpod](https://riverpod.dev/) - 状态管理
- [Hive](https://docs.hivedb.dev/) - 本地数据库
- [audioplayers](https://pub.dev/packages/audioplayers) - 音频播放

## 🤝 贡献

欢迎贡献代码！请阅读 [贡献指南](CONTRIBUTING.md) 了解详情。

## 📄 开源协议

本项目采用 [MIT License](LICENSE) 开源协议。

## 🙏 致谢

感谢所有贡献者和用户的支持！

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/mxrain">mxrain</a>
</p>
