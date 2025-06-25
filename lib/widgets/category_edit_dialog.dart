import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sound_category.dart';
import '../providers/sound_provider.dart';

class CategoryEditDialog extends ConsumerStatefulWidget {
  final SoundCategory? category;
  
  const CategoryEditDialog({
    Key? key,
    this.category,
  }) : super(key: key);

  @override
  ConsumerState<CategoryEditDialog> createState() => _CategoryEditDialogState();
}

class _CategoryEditDialogState extends ConsumerState<CategoryEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    
    // 如果是编辑模式，填充已有数据
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  
  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final name = _nameController.text.trim();
    
    setState(() => _isLoading = true);
    
    try {
      final soundManager = ref.read(soundManagerProvider.notifier);
      
      if (widget.category == null) {
        // 创建新分类
        await soundManager.addCategory(name);
      } else {
        // 更新现有分类
        final updatedCategory = SoundCategory(
          id: widget.category!.id,
          name: name,
          soundIds: widget.category!.soundIds,
          order: widget.category!.order,
        );
        
        await soundManager.updateCategory(updatedCategory);
      }
      
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;
    
    return AlertDialog(
      title: Text(isEditing ? '编辑分类' : '添加分类'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '名称',
                hintText: '输入分类名称',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入名称';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveCategory,
          child: _isLoading 
              ? const SizedBox(
                  width: 16, 
                  height: 16, 
                  child: CircularProgressIndicator(strokeWidth: 2),
                ) 
              : Text(isEditing ? '保存' : '添加'),
        ),
      ],
    );
  }
} 