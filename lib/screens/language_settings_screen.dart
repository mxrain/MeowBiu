import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _currentLocale = 'zh'; // 默认为中文
  
  @override
  void initState() {
    super.initState();
    _loadCurrentLocale();
  }
  
  // 加载当前语言设置
  Future<void> _loadCurrentLocale() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLocale = prefs.getString('language_code') ?? 'zh';
    });
  }
  
  // 保存语言设置
  Future<void> _saveLocale(String localeCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', localeCode);
    setState(() {
      _currentLocale = localeCode;
    });
    
    // 显示提示
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('语言设置已更改，重启应用后生效'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('语言设置'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '选择应用界面语言',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // 中文选项
          _buildLanguageOption(
            context: context,
            title: '简体中文', 
            subtitle: '简体中文',
            locale: 'zh',
            selected: _currentLocale == 'zh',
          ),
          
          // 英文选项
          _buildLanguageOption(
            context: context,
            title: 'English',
            subtitle: 'English',
            locale: 'en',
            selected: _currentLocale == 'en',
          ),
          
          const SizedBox(height: 24),
          
          // 提示信息
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              '注意：语言设置将在应用重启后生效',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建语言选项
  Widget _buildLanguageOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String locale,
    required bool selected,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: selected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () {
        _saveLocale(locale);
      },
    );
  }
} 