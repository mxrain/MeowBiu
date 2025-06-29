import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/cat_sound.dart';
import '../models/sound_category.dart';
import '../providers/sound_provider.dart';
import '../widgets/category_selector.dart';
import '../widgets/chat_sounds_list.dart';
import '../widgets/sound_edit_dialog.dart';
import '../widgets/category_edit_dialog.dart';
import 'about_screen.dart';
import 'storage_settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentNavIndex = 0; // 当前选中的底部导航索引
  
  // 显示添加猫声对话框
  Future<void> _showAddSoundDialog(String categoryId) async {
    await showDialog(
      context: context,
      builder: (context) => SoundEditDialog(categoryId: categoryId),
    );
  }
  
  // 显示编辑猫声对话框
  Future<void> _showEditSoundDialog(CatSound sound) async {
    await showDialog(
      context: context,
      builder: (context) => SoundEditDialog(sound: sound),
    );
  }
  
  // 显示添加分类对话框
  Future<void> _showAddCategoryDialog() async {
    await showDialog(
      context: context,
      builder: (context) => const CategoryEditDialog(),
    );
  }
  
  // 显示编辑分类对话框
  Future<void> _showEditCategoryDialog(SoundCategory category) async {
    await showDialog(
      context: context,
      builder: (context) => CategoryEditDialog(category: category),
    );
  }
  
  // 复制分类
  Future<void> _copyCategory(SoundCategory category) async {
    // 创建一个新的分类名称，格式为"原名称 副本"
    final newCategoryName = '${category.name} 副本';
    
    // 创建新分类并获取ID
    final newCategory = await ref.read(soundManagerProvider.notifier).addCategory(newCategoryName);
    
    if (newCategory != null) {
      // 获取原分类下的所有音频
      final sounds = await ref.watch(categorySoundsProvider(category.id).future);
      
      // 复制每个音频到新分类
      for (final sound in sounds) {
        await ref.read(soundManagerProvider.notifier).addSound(
          name: sound.name,
          audioPath: sound.audioPath,
          sourceType: sound.sourceType,
          categoryId: newCategory.id,
        );
      }
      
      // 显示成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('分类"${category.name}"复制成功')),
        );
      }
    }
  }
  
  // 删除分类
  Future<void> _deleteCategory(SoundCategory category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除分类'),
        content: Text('确定要删除"${category.name}"分类吗？这将移除所有关联的猫声。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await ref.read(soundManagerProvider.notifier).deleteCategory(category.id);
    }
  }
  
  // 删除猫声
  Future<void> _deleteSound(CatSound sound) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除猫声'),
        content: Text('确定要删除"${sound.name}"猫声吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await ref.read(soundManagerProvider.notifier).deleteSound(sound.id);
    }
  }
  
  // 清理单个猫声的缓存
  Future<void> _clearSoundCache(CatSound sound) async {
    if (!sound.isCached) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清理缓存'),
        content: Text('确定要清理"${sound.name}"的缓存吗？这可能会影响离线播放。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('清理'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final result = await ref.read(soundManagerProvider.notifier).clearSoundCache(sound);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result ? '缓存清理成功' : '缓存清理失败')),
        );
      }
    }
  }
  
  // 复制音频
  Future<void> _copySoundItem(CatSound sound) async {
    // 创建新的音频名称
    final newSoundName = '${sound.name}(副本)';
    
    // 获取当前分类ID
    final String? currentCategoryId = ref.read(selectedCategoryProvider);
    
    // 添加复制后的音频
    final newSound = await ref.read(soundManagerProvider.notifier).addSound(
      name: newSoundName,
      audioPath: sound.audioPath,
      sourceType: sound.sourceType,
      categoryId: currentCategoryId,
    );
    
    if (newSound != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('音频"${sound.name}"复制成功')),
      );
    }
  }
  
  // 处理分类长按事件
  void _handleCategoryLongPress(SoundCategory category) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('重命名分类'),
              onTap: () {
                Navigator.of(context).pop();
                _showEditCategoryDialog(category);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('复制分类'),
              onTap: () {
                Navigator.of(context).pop();
                _copyCategory(category);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除分类', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                _deleteCategory(category);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final selectedCategory = ref.watch(selectedCategoryProvider);
    
    // 创建AppBar - 聊天风格的顶部栏
    final appBar = AppBar(
      title: const Text('猫语', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
      centerTitle: true,
      actions: [
        // 设置按钮
        IconButton(
          icon: SvgPicture.asset(
            'assets/images/icon_settings_gear.svg',
            height: 32,
            colorFilter: ColorFilter.mode(colorScheme.onSurface, BlendMode.srcIn),
          ),
          tooltip: '设置',
          onPressed: () {
            // 添加轻微触觉反馈
            HapticFeedback.lightImpact();
            // 打开右侧抽屉
            _scaffoldKey.currentState?.openEndDrawer();
          },
        ),
      ],
    );
    
    // 构建主体内容
    final bodyContent = categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('暂无分类，请先添加分类'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _showAddCategoryDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('添加分类'),
                ),
              ],
            ),
          );
        }
        
        // 确保有选定的分类
        String currentCategoryId = selectedCategory ?? categories.first.id;
        
        // 使用聊天UI风格布局
        return _currentNavIndex == 0
            ? Column(
                children: [
                  // 分类选择器
                  CategorySelector(
                    categories: categories,
                    selectedCategoryId: currentCategoryId,
                    onSelectCategory: (categoryId) {
                      ref.read(selectedCategoryProvider.notifier).state = categoryId;
                    },
                    onAddCategory: _showAddCategoryDialog,
                    onLongPressCategory: _handleCategoryLongPress,
                  ),
                  
                  // 聊天列表
                  Expanded(
                    child: ChatSoundsList(
                      categoryId: currentCategoryId,
                      onAddSound: () => _showAddSoundDialog(currentCategoryId),
                      onEditSound: _showEditSoundDialog,
                      onDeleteSound: _deleteSound,
                      onClearCache: _clearSoundCache,
                      onCopySound: _copySoundItem,
                    ),
                  ),
                ],
              )
            : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mic, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('录音功能即将上线'),
                  ],
                ),
              );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('加载失败: $error'),
      ),
    );
    
    // 使用Scaffold包装
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBar,
      body: bodyContent,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: colorScheme.primary.withOpacity(0.1),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.primary,
              );
            }
            return TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            );
          }),
        ),
        child: NavigationBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          selectedIndex: _currentNavIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentNavIndex = index;
            });
          },
          destinations: [
            NavigationDestination(
              icon: SvgPicture.asset(
                'assets/images/icon_nav_cat.svg',
                height: 24,
                colorFilter: ColorFilter.mode(
                  _currentNavIndex == 0 
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
              ),
              label: '猫声',
            ),
            NavigationDestination(
              icon: SvgPicture.asset(
                'assets/images/icon_nav_mic.svg',
                height: 24,
                colorFilter: ColorFilter.mode(
                  _currentNavIndex == 1 
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
              ),
              label: '录音',
            ),
          ],
        ),
      ),
      // 悬浮按钮 - 添加音频
      floatingActionButton: _currentNavIndex == 0 ? FloatingActionButton(
        onPressed: () {
          final selectedCategory = ref.watch(selectedCategoryProvider);
          if (selectedCategory != null) {
            _showAddSoundDialog(selectedCategory);
          }
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: SvgPicture.asset(
          'assets/images/icon_add_bottom.svg',
          height: 24,
          colorFilter: ColorFilter.mode(colorScheme.onPrimary, BlendMode.srcIn),
        ),
      ) : null,
      endDrawer: SizedBox(
        width: 360.0, // 固定抽屉宽度为360dp
        child: SafeArea(
          child: Drawer(
            child: Column(
              children: [
                // 抽屉头部
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 32, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '设置',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // 设置项
                _buildSettingItem(
                  context,
                  icon: Icons.color_lens_outlined,
                  title: '主题设置',
                  description: '自定义应用主题颜色和深色模式',
                  onTap: () {
                    _handleItemTap(context, '/theme-settings');
                  },
                ),

                _buildSettingItem(
                  context,
                  icon: Icons.volume_up_outlined,
                  title: '音频设置',
                  description: '调整音量和播放选项',
                  onTap: () {
                    _handleItemTap(context, '/audio-settings');
                  },
                ),

                _buildSettingItem(
                  context,
                  icon: Icons.cloud_outlined,
                  title: '存储与缓存',
                  description: '管理音频缓存和存储空间',
                  onTap: () {
                    _handleItemTap(context, '/storage-settings');
                  },
                ),

                _buildSettingItem(
                  context,
                  icon: Icons.notifications_outlined,
                  title: '通知设置',
                  description: '管理应用通知和提醒',
                  onTap: () {
                    _handleItemTap(context, '/notification-settings');
                  },
                ),

                const Divider(),

                _buildSettingItem(
                  context,
                  icon: Icons.help_outline,
                  title: '帮助与反馈',
                  description: '获取帮助或提交问题反馈',
                  onTap: () {
                    _handleItemTap(context, '/help');
                  },
                ),
                
                // 关于入口 - 放在设置列表的最后一项
                _buildSettingItem(
                  context,
                  icon: Icons.info_rounded,
                  title: '关于',
                  description: '版本、意见反馈、自动更新',
                  onTap: () {
                    _handleItemTap(context, '/about');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      onEndDrawerChanged: (isOpened) {
        if (isOpened) {
          HapticFeedback.mediumImpact();
        }
      },
    );
  }
  
  // 创建单个设置项
  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: colorScheme.primary,
          size: 28,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
      ),
    );
  }

  // 处理设置项点击
  void _handleItemTap(BuildContext context, String route) {
    // 关闭抽屉
    Navigator.pop(context);
    
    // 根据路由导航到相应页面
    if (route == '/about') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AboutScreen()),
      );
    } else if (route == '/storage-settings') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StorageSettingsScreen()),
      );
    } else {
      // 其他路由暂时只显示一个SnackBar提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('导航到: $route'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}