# 喵喵语录应用语言管理指南

本文档提供了关于应用程序国际化功能的完整指南，包括如何添加新语言、删除现有语言、修改翻译文本、以及如何在组件中使用国际化文字。

## 目录

- [概述](#概述)
- [语言系统架构](#语言系统架构)
- [添加新语言](#添加新语言)
- [删除现有语言](#删除现有语言)
- [修改翻译文本](#修改翻译文本)
- [在组件中使用国际化文字](#在组件中使用国际化文字)
- [动态切换语言](#动态切换语言)
- [常见问题解答](#常见问题解答)

## 概述

喵喵语录应用采用了 Flutter 官方的国际化方案，使用 `flutter_localizations` 和 `intl` 包来实现多语言支持。目前，应用支持以下语言：

- 简体中文 (zh)
- 英语 (en)

语言设置保存在应用的 SharedPreferences 中，使用 `language_code` 作为键。应用启动时会自动加载上次设置的语言，也可以在设置界面中随时切换语言，切换后会立即生效而无需重启应用。

## 语言系统架构

应用的国际化系统主要包含以下组件：

1. **ARB 资源文件**：`lib/l10n` 目录下的 `.arb` 文件，包含各个语言的翻译文本
2. **生成的国际化代码**：`lib/l10n/generated` 目录下的自动生成代码
3. **语言Provider**：`lib/providers/locale_provider.dart` 文件，负责管理语言状态
4. **语言设置界面**：`lib/screens/language_settings_screen.dart` 文件，提供用户界面

配置文件：
- `l10n.yaml`：定义了国际化生成器的配置
- `pubspec.yaml`：包含国际化所需的依赖

## 添加新语言

要添加新语言支持，请按照以下步骤操作：

### 1. 创建新的语言资源文件

在 `lib/l10n` 目录下创建新的 ARB 文件。文件命名格式为 `app_<语言代码>.arb`，例如 `app_ja.arb` 用于日语支持。

可以复制现有的资源文件（如 `app_en.arb`），然后翻译其中的文本。示例：

```json
{
  "appTitle": "ミャオ語録",
  "@appTitle": {
    "description": "Application title"
  },
  "settings": "設定",
  "@settings": {
    "description": "Settings title"
  },
  // 其他翻译内容...
}
```

### 2. 更新 `l10n.yaml` 文件（如有必要）

通常情况下不需要修改此文件，因为它已经配置为自动识别所有 `lib/l10n` 目录下的 ARB 文件。

### 3. 生成国际化文件

运行以下命令生成国际化代码：

```bash
flutter gen-l10n
```

这将在 `lib/l10n/generated` 目录下生成新的语言支持文件。

### 4. 更新支持的语言列表（可选）

如果您想在语言设置界面中添加新语言的选项，需要修改 `lib/screens/language_settings_screen.dart` 文件：

```dart
// 添加新的语言选项
_buildLanguageOption(
  context: context,
  title: localizations.japanese, // 需要在ARB文件中添加此条目
  subtitle: '日本語',
  locale: 'ja',
  selected: currentLocale == 'ja',
),
```

## 删除现有语言

如果您想移除某种语言支持，请按照以下步骤操作：

### 1. 删除对应的 ARB 文件

从 `lib/l10n` 目录删除不再需要的语言资源文件，例如 `app_ja.arb`。

### 2. 从语言设置界面移除选项

修改 `lib/screens/language_settings_screen.dart` 文件，删除对应语言的选项。

### 3. 重新生成国际化文件

运行以下命令更新生成的代码：

```bash
flutter gen-l10n
```

### 4. 确保默认语言设置正确

如果删除了当前正在使用的语言，请确保在 `lib/providers/locale_provider.dart` 中设置了合适的默认语言：

```dart
LocaleNotifier() : super('zh') { // 设置默认语言为中文
  _loadSavedLocale();
}
```

## 修改翻译文本

要修改现有翻译，只需编辑对应语言的 ARB 文件，然后重新生成国际化代码：

1. 打开需要修改的语言文件，如 `lib/l10n/app_zh.arb`
2. 修改相应的文本内容
3. 运行 `flutter gen-l10n` 重新生成代码

## 在组件中使用国际化文字

要在应用中使用国际化文字，请按照以下步骤操作：

### 1. 导入本地化包

```dart
import '../l10n/generated/app_localizations.dart';
```

### 2. 在构建方法中获取本地化对象

```dart
@override
Widget build(BuildContext context) {
  final localizations = AppLocalizations.of(context)!;
  
  return Scaffold(
    appBar: AppBar(
      title: Text(localizations.appTitle),
    ),
    // ...
  );
}
```

### 3. 使用本地化字符串

```dart
Text(localizations.settings)
```

### 4. 为新的文本添加国际化支持

如果需要添加新的可翻译文本，请按照以下步骤操作：

1. 在所有语言的 ARB 文件中添加新条目，例如：

   在 `app_zh.arb` 中：
   ```json
   "newFeature": "新功能",
   "@newFeature": {
     "description": "新功能标题"
   }
   ```

   在 `app_en.arb` 中：
   ```json
   "newFeature": "New Feature",
   "@newFeature": {
     "description": "New feature title"
   }
   ```

2. 运行 `flutter gen-l10n` 重新生成代码
3. 在代码中使用新添加的本地化字符串：
   ```dart
   Text(localizations.newFeature)
   ```

## 动态切换语言

应用支持实时切换语言，无需重启。这是通过 `localeProvider` 实现的：

```dart
// 更改语言
await ref.read(localeProvider.notifier).changeLocale('en');
```

切换语言时，框架会自动更新界面上所有使用国际化文本的组件。

## 常见问题解答

### Q: 切换语言后部分文本没有更新？

A: 确保所有文本都使用了 `AppLocalizations.of(context)!` 获取的本地化字符串。硬编码的文本不会随语言切换而更新。

### Q: 添加了新语言但是没有显示在应用中？

A: 确保完成了以下步骤：
1. 创建了正确命名的 ARB 文件
2. 运行了 `flutter gen-l10n` 命令
3. 在语言设置页面添加了新语言的选项
4. 重新启动应用

### Q: 如何添加带有参数的翻译字符串？

A: 在 ARB 文件中可以使用占位符，例如：

```json
"greetingMessage": "你好，{username}！",
"@greetingMessage": {
  "description": "带有用户名的问候语",
  "placeholders": {
    "username": {
      "type": "String",
      "example": "张三"
    }
  }
}
```

然后在代码中使用：

```dart
Text(localizations.greetingMessage('张三'))
```

### Q: 如何添加复数形式？

A: ARB 文件支持复数形式，例如：

```json
"catCount": "{count, plural, =0{没有猫} =1{1只猫} other{{count}只猫}}",
"@catCount": {
  "description": "猫的数量",
  "placeholders": {
    "count": {
      "type": "int",
      "example": "3"
    }
  }
}
```

然后在代码中使用：

```dart
Text(localizations.catCount(3))
``` 