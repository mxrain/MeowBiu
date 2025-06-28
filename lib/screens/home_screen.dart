import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/cat_sound.dart';
import '../models/sound_category.dart';
import '../providers/sound_provider.dart';
import '../widgets/cat_sound_button.dart';
import '../widgets/sound_edit_dialog.dart';
import '../widgets/category_edit_dialog.dart';
import 'about_screen.dart';
import 'storage_settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final categoriesAsync = ref.watch(categoriesProvider);
    categoriesAsync.whenData((categories) {
      if (categories.isEmpty) return;
      
      // 如果Tab控制器尚未初始化，或者分类数量变化，重新创建控制器
      if (_tabController == null || _tabController!.length != categories.length) {
        _tabController?.dispose();
        _tabController = TabController(
          length: categories.length,
          vsync: this,
        );
        
        // 确保选中的分类是有效的
        final selectedCategory = ref.read(selectedCategoryProvider);
        if (selectedCategory == null || !categories.any((c) => c.id == selectedCategory)) {
          ref.read(selectedCategoryProvider.notifier).state = categories.first.id;
        }
      }
    });
  }
  
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
  
  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    
    // 创建AppBar
    final appBar = AppBar(
      title: const Text('音频'),
      actions: [
        // 设置按钮
        IconButton(
          icon: const Icon(Icons.settings_outlined),
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
          return const Center(
            child: Text('暂无分类，请先添加分类'),
          );
        }
        
        // 使用DefaultTabController包裹整个内容区域
        return DefaultTabController(
          length: categories.length,
          child: Column(
            children: [
              // 顶部Tab栏和添加分类按钮
              Container(
                decoration: const BoxDecoration(
                  // 去除下边框线
                  border: Border(),
                ),
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    // 标签栏，靠左对齐
                    TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      // 自定义下划线指示器
                      indicator: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      dividerColor: Colors.transparent,  // 移除底部分割线
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4), // 减小Tab之间的间距
                      indicatorSize: TabBarIndicatorSize.label,
                      // 禁用触摸反馈效果
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                      tabs: categories.map((category) {
                        return Tab(
                          child: GestureDetector(
                            onLongPress: () {
                              // 从屏幕中央弹出菜单
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('分类操作'),
                                  content: Column(
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
                            },
                            child: Text(category.name),
                          ),
                        );
                      }).toList(),
                      onTap: (index) {
                        ref.read(selectedCategoryProvider.notifier).state = categories[index].id;
                      },
                    ),
                    
                    // 添加分类按钮，固定在最右侧
                    Positioned(
                      right: 0,
                      child: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: IconButton(
                          icon: const Icon(Icons.add),
                          tooltip: '添加分类',
                          onPressed: _showAddCategoryDialog,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 内容区域
              Expanded(
                child: TabBarView(
                  children: categories.map((category) {
                    return CategorySoundsGrid(
                      categoryId: category.id,
                      onAddSound: () => _showAddSoundDialog(category.id),
                      onEditSound: _showEditSoundDialog,
                      onDeleteSound: _deleteSound,
                      onClearCache: _clearSoundCache,
                    );
                  }).toList(),
                ),
              ),
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
      endDrawer: Container(
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

class CategorySoundsGrid extends ConsumerWidget {
  final String categoryId;
  final VoidCallback onAddSound;
  final Function(CatSound) onEditSound;
  final Function(CatSound) onDeleteSound;
  final Function(CatSound) onClearCache;
  
  const CategorySoundsGrid({
    Key? key,
    required this.categoryId,
    required this.onAddSound,
    required this.onEditSound,
    required this.onDeleteSound,
    required this.onClearCache,
  }) : super(key: key);
  
  // 复制音频功能
  Future<void> _copySoundItem(BuildContext context, WidgetRef ref, CatSound sound) async {
    // 创建新的音频名称
    final newSoundName = '${sound.name}(副本)';
    
    // 添加复制后的音频
    final newSound = await ref.read(soundManagerProvider.notifier).addSound(
      name: newSoundName,
      audioPath: sound.audioPath,
      sourceType: sound.sourceType,
      categoryId: categoryId,
    );
    
    if (newSound != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('音频"${sound.name}"复制成功')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundsAsync = ref.watch(categorySoundsProvider(categoryId));
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      child: soundsAsync.when(
        data: (sounds) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // 音频列表区域 - 更紧凑的设计
              Positioned.fill(
                bottom: 60, // 为底部添加按钮留出空间
                child: sounds.isEmpty
                    ? const SizedBox() // 如果没有音频，不显示列表
                    : ListView.separated(
                        itemCount: sounds.length,
                        // 使用极细分隔线
                        separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.2),
                        itemBuilder: (context, index) {
                          final sound = sounds[index];
                          return GestureDetector(
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('音频操作'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.edit),
                                        title: const Text('编辑'),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          onEditSound(sound);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.copy),
                                        title: const Text('复制'),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          _copySoundItem(context, ref, sound);
                                        },
                                      ),
                                      if (sound.isNetworkSource && sound.isCached)
                                        ListTile(
                                          leading: const Icon(Icons.cleaning_services),
                                          title: const Text('清理缓存'),
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            onClearCache(sound);
                                          },
                                        ),
                                      ListTile(
                                        leading: const Icon(Icons.delete, color: Colors.red),
                                        title: const Text('删除', style: TextStyle(color: Colors.red)),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          onDeleteSound(sound);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: CatSoundButton(
                              sound: sound,
                            ),
                          );
                        },
                      ),
              ),
              
              // 空状态提示 - 添加动画效果
              if (sounds.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('暂无音频，点击添加'),
                      const SizedBox(height: 16),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 1.0, end: 1.1),
                        duration: const Duration(seconds: 2),
                        curve: Curves.elasticInOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: ElevatedButton.icon(
                              onPressed: onAddSound,
                              icon: const Icon(Icons.add),
                              label: const Text('添加音频'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              
              // 添加按钮移至底部中央
              if (sounds.isNotEmpty)
                Positioned(
                  bottom: 16,
                  child: FloatingActionButton.extended(
                    onPressed: onAddSound,
                    icon: const Icon(Icons.add),
                    label: const Text('添加音频'),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('加载失败: $error'),
        ),
      ),
    );
  }
}