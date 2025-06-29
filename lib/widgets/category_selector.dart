import 'package:flutter/material.dart';
import '../models/sound_category.dart';

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
    final theme = Theme.of(context);
    
    return Container(
      height: 56,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1, // +1 用于添加按钮
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          // 最后一个是添加分类按钮
          if (index == categories.length) {
            return Center(
              child: IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 28),
                tooltip: '添加分类',
                onPressed: onAddCategory,
              ),
            );
          }
          
          final category = categories[index];
          final isSelected = category.id == selectedCategoryId;
          
          return GestureDetector(
            onLongPress: () => onLongPressCategory(category),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected 
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => onSelectCategory(category.id),
                backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.7),
                selectedColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
            ),
          );
        },
      ),
    );
  }
} 