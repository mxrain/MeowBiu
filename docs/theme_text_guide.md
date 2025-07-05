# 将文本纳入主题系统指南

本文档提供关于如何在喵喵语录应用中将文本纳入主题系统的详细说明，实现统一的文本样式管理和暗黑模式适配。

## 目录

- [概述](#概述)
- [主题系统架构](#主题系统架构)
- [文本样式定义](#文本样式定义)
- [在组件中使用主题化文本](#在组件中使用主题化文本)
- [暗黑模式适配](#暗黑模式适配)
- [国际化与主题系统集成](#国际化与主题系统集成)
- [最佳实践](#最佳实践)

## 概述

Flutter提供了强大的主题系统，可以定义应用全局的文本样式。通过将文本纳入主题系统，可以：

1. 保持应用中文本样式的一致性
2. 轻松实现暗黑模式适配
3. 简化文本样式的管理和更新
4. 提高代码可维护性

喵喵语录应用使用 Material Design 3 (Material You) 的主题系统，通过 `ThemeData` 定义统一的样式规范。

## 主题系统架构

应用的主题系统主要包含以下组件：

1. **主题定义**：在 `main.dart` 中使用 `ThemeData` 定义亮色和暗色主题
2. **文本主题**：使用 `TextTheme` 定义不同用途的文本样式
3. **色彩方案**：使用 `ColorScheme` 定义应用的颜色系统

## 文本样式定义

### Material Design 3 文本样式层次结构

Flutter 的 Material Design 3 提供了一套完整的文本样式层次结构：

| 样式名称 | 用途 |
|---------|------|
| `displayLarge` | 最大的标题，用于展示页面 |
| `displayMedium` | 中等大小的展示文本 |
| `displaySmall` | 小号展示文本 |
| `headlineLarge` | 大号标题 |
| `headlineMedium` | 中号标题，通常用于页面主标题 |
| `headlineSmall` | 小号标题 |
| `titleLarge` | 大号标题文本 |
| `titleMedium` | 中号标题文本，如对话框标题 |
| `titleSmall` | 小号标题文本 |
| `bodyLarge` | 大号正文文本 |
| `bodyMedium` | 中号正文文本，默认文本样式 |
| `bodySmall` | 小号正文文本 |
| `labelLarge` | 大号标签文本，如按钮文字 |
| `labelMedium` | 中号标签文本 |
| `labelSmall` | 小号标签文本，如提示信息 |

### 在应用中定义主题文本样式

修改 `main.dart` 中的 `ThemeData` 定义，添加或调整 `textTheme`：

```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  useMaterial3: true,
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
    ),
    // 其他文本样式...
  ),
)
```

## 在组件中使用主题化文本

### 基本用法

```dart
Text(
  '设置',
  style: Theme.of(context).textTheme.headlineMedium,
)
```

### 带有颜色调整

```dart
Text(
  '设置',
  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
    color: Theme.of(context).colorScheme.primary,
  ),
)
```

### 组合国际化文本与主题样式

```dart
final localizations = AppLocalizations.of(context)!;

Text(
  localizations.settings,
  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
    color: Theme.of(context).colorScheme.primary,
    fontWeight: FontWeight.bold,
  ),
)
```

## 暗黑模式适配

### 定义暗黑模式主题

```dart
darkTheme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
  // 可以根据需要调整暗黑模式下的文本样式
  textTheme: TextTheme(
    // 暗黑模式下特定的文本样式调整
  ),
)
```

### 颜色适配最佳实践

始终使用 `colorScheme` 中的语义颜色而非硬编码颜色值：

```dart
// 不推荐
Text(
  'Title',
  style: TextStyle(color: Colors.black), // 在暗黑模式下不会自动适配
)

// 推荐
Text(
  'Title',
  style: TextStyle(color: Theme.of(context).colorScheme.onSurface), // 会根据主题自动适配
)
```

常用的语义颜色包括：
- `primary`: 主色调
- `onPrimary`: 主色调上的文本颜色
- `secondary`: 次要色调
- `onSecondary`: 次要色调上的文本颜色
- `surface`: 表面颜色
- `onSurface`: 表面上的文本颜色
- `background`: 背景色
- `onBackground`: 背景上的文本颜色
- `error`: 错误颜色
- `onError`: 错误颜色上的文本颜色

## 国际化与主题系统集成

当将国际化系统与主题系统结合使用时，需要注意以下几点：

### 1. 使用正确的文本方向

对于支持从右到左(RTL)语言（如阿拉伯语或希伯来语）的应用，确保使用 `Directionality` 或让 Flutter 的国际化系统自动处理：

```dart
MaterialApp(
  locale: Locale(currentLocale),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  // Flutter会自动根据语言调整文本方向
)
```

### 2. 考虑不同语言的文本长度

不同语言的同一段文本长度可能相差很大，在设计UI时应考虑这一点：

- 使用可伸缩的容器而非固定尺寸
- 为长文本使用 `Expanded` 或 `Flexible` 
- 考虑使用 `AutoSizeText` 处理特别长的文本

### 3. 字体支持

确保您选择的字体支持所有目标语言的字符集。对于中文等CJK语言，需要使用支持这些字符的字体：

```dart
ThemeData(
  fontFamily: 'NotoSansSC', // 支持中文的Google Noto字体
  // ...
)
```

## 最佳实践

### 1. 保持样式一致性

- 为常见UI元素定义一致的样式
- 遵循预定义的文本层次结构
- 不要随意覆盖主题样式

### 2. 创建通用组件

创建封装了主题样式的通用组件，以提高代码复用：

```dart
class SectionTitle extends StatelessWidget {
  final String text;
  
  const SectionTitle({required this.text, Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}
```

### 3. 避免硬编码样式

尽量避免在组件中定义硬编码的样式，而是使用主题提供的样式：

```dart
// 不推荐
Text(
  'Title',
  style: TextStyle(
    fontSize: 16, 
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  ),
)

// 推荐
Text(
  'Title',
  style: Theme.of(context).textTheme.titleMedium,
)
```

### 4. 使用响应式设计

确保文本样式在不同屏幕尺寸下表现良好：

```dart
// 根据屏幕宽度调整文本大小
TextStyle getResponsiveHeadline(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  final baseStyle = Theme.of(context).textTheme.headlineMedium!;
  
  if (width < 360) {
    return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 0.8);
  }
  
  return baseStyle;
}
```

## 总结

将文本纳入主题系统是构建一致、可维护和可适应不同设备与语言应用的关键步骤。通过遵循本指南中的建议，可以创建出视觉统一且用户体验良好的应用界面。 