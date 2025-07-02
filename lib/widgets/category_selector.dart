import 'package:flutter/material.dart';
import '../models/sound_category.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategorySelector extends StatelessWidget {
  final List<SoundCategory> categories;
  final String selectedCategoryId;
  final Function(String) onSelectCategory;
  final VoidCallback onAddCategory;
  final Function(SoundCategory) onLongPressCategory;
  
  const CategorySelector({
    Key? key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelectCategory,
    required this.onAddCategory,
    required this.onLongPressCategory,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        children: [
          // 滚动列表
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white,
                  Colors.white,
                  Colors.white.withOpacity(0.0),
                ],
                stops: const [0.0, 0.85, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category.id == selectedCategoryId;
                
                // 计算标签内边距
                final labelHeight = 6.0; // 内容高度外加的内边距
                final labelWidth = 4.0;  // 内容宽度外加的内边距
                
                return GestureDetector(
                  onLongPress: () => onLongPressCategory(category),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onSelectCategory(category.id),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected 
                                    ? Colors.white 
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 固定在右侧的添加按钮
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                  stops: const [0.0, 0.5],
                ),
              ),
              child: Center(
                child: Container(
                  height: 36, // 与分类标签一致的高度
                  child: IconButton(
                    padding: EdgeInsets.zero, // 移除默认padding
                    constraints: const BoxConstraints(), // 移除约束
                    icon: SvgPicture.asset(
                      'assets/images/icon_category_add_bottom.svg',
                      width: 28,
                      height: 28,
                    ),
                    tooltip: '添加分类',
                    onPressed: onAddCategory,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
