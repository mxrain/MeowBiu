import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'settings_drawer.dart';

/// 应用的基础脚手架，包含右侧导航抽屉实现
class AppScaffold extends StatefulWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const AppScaffold({
    Key? key,
    required this.child,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  }) : super(key: key);

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  // 控制抽屉的状态
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 打开抽屉方法
  void openDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    // 检测屏幕宽度以实现自适应布局
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900; // 大屏幕阈值
    
    // 设置抽屉宽度
    final drawerWidth = 360.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 在大屏幕上使用固定显示的抽屉，在小屏幕上使用抽屉式导航
        if (isLargeScreen) {
          // 大屏幕布局 - 固定显示侧边栏
          return Scaffold(
            appBar: widget.appBar,
            body: Row(
              children: [
                // 主内容区
                Expanded(child: widget.child),
                
                // 右侧固定显示的设置抽屉
                SizedBox(
                  width: drawerWidth,
                  child: const SettingsDrawer(),
                ),
              ],
            ),
          );
        } else {
          // 小屏幕布局 - 使用抽屉式导航
          return Scaffold(
            key: _scaffoldKey,
            appBar: widget.appBar,
            body: widget.child,
            // 右侧抽屉
            endDrawer: Container(
              width: drawerWidth,
              child: SettingsDrawer(
                onClose: () {
                  Navigator.pop(context);
                },
              ),
            ),
            // 自定义抽屉宽度
            drawerEdgeDragWidth: 20,
            // 抽屉打开/关闭时的触觉反馈
            onEndDrawerChanged: (isOpened) {
              if (isOpened) {
                HapticFeedback.mediumImpact();
              }
            },
            floatingActionButton: widget.floatingActionButton ??
                FloatingActionButton(
                  onPressed: openDrawer,
                  tooltip: '设置',
                  child: const Icon(Icons.settings_outlined),
                ),
            floatingActionButtonLocation: 
                widget.floatingActionButtonLocation ?? 
                FloatingActionButtonLocation.endFloat,
          );
        }
      },
    );
  }
} 