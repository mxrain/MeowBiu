#!/usr/bin/env dart
/// 版本号管理脚本
/// 用法: dart scripts/bump_version.dart [major|minor|patch] [--dry-run]

import 'dart:io';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('用法: dart scripts/bump_version.dart [major|minor|patch] [--dry-run]');
    print('示例: dart scripts/bump_version.dart patch');
    exit(1);
  }

  final bumpType = args[0];
  final dryRun = args.contains('--dry-run');

  if (!['major', 'minor', 'patch'].contains(bumpType)) {
    print('错误: 无效的版本类型 "$bumpType"');
    print('有效类型: major, minor, patch');
    exit(1);
  }

  // 读取 pubspec.yaml
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print('错误: 找不到 pubspec.yaml');
    exit(1);
  }

  final content = pubspecFile.readAsStringSync();
  final versionMatch = RegExp(r'version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)').firstMatch(content);

  if (versionMatch == null) {
    print('错误: 无法解析版本号');
    exit(1);
  }

  var major = int.parse(versionMatch.group(1)!);
  var minor = int.parse(versionMatch.group(2)!);
  var patch = int.parse(versionMatch.group(3)!);
  var build = int.parse(versionMatch.group(4)!);

  final oldVersion = '$major.$minor.$patch+$build';

  // 更新版本号
  switch (bumpType) {
    case 'major':
      major++;
      minor = 0;
      patch = 0;
      break;
    case 'minor':
      minor++;
      patch = 0;
      break;
    case 'patch':
      patch++;
      break;
  }
  build++;

  final newVersion = '$major.$minor.$patch+$build';

  print('版本更新: $oldVersion -> $newVersion');

  if (dryRun) {
    print('[Dry Run] 不会实际修改文件');
    return;
  }

  // 更新 pubspec.yaml
  final newContent = content.replaceFirst(
    RegExp(r'version:\s*\d+\.\d+\.\d+\+\d+'),
    'version: $newVersion',
  );
  pubspecFile.writeAsStringSync(newContent);
  print('✓ 已更新 pubspec.yaml');

  // 更新 CHANGELOG.md
  final changelogFile = File('CHANGELOG.md');
  if (changelogFile.existsSync()) {
    final changelog = changelogFile.readAsStringSync();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final newChangelog = changelog.replaceFirst(
      '## [Unreleased]',
      '## [Unreleased]\n\n## [$major.$minor.$patch] - $today',
    );
    changelogFile.writeAsStringSync(newChangelog);
    print('✓ 已更新 CHANGELOG.md');
  }

  print('\n下一步:');
  print('  1. 更新 CHANGELOG.md 中的变更内容');
  print('  2. git add .');
  print('  3. git commit -m "chore: bump version to $major.$minor.$patch"');
  print('  4. git tag v$major.$minor.$patch');
  print('  5. git push origin main --tags');
}
