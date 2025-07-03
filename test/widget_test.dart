// 基础Flutter控件测试文件

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meow_biu/main.dart';

void main() {
  testWidgets('应用启动测试', (WidgetTester tester) async {
    // 构建应用并触发渲染
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // 验证应用成功启动
    expect(find.byType(MaterialApp), findsOneWidget);
  });
} 