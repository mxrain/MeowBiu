import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/generated/app_localizations.dart';
import '../providers/locale_provider.dart';

class LanguageSettingsScreen extends ConsumerStatefulWidget {
  const LanguageSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends ConsumerState<LanguageSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // 从Provider获取当前语言设置
    final currentLocale = ref.watch(localeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.languageSettings),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              localizations.selectLanguage,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // 中文选项
          _buildLanguageOption(
            context: context,
            title: localizations.simplifiedChinese, 
            subtitle: '简体中文',
            locale: 'zh',
            selected: currentLocale == 'zh',
          ),
          
          // 英文选项
          _buildLanguageOption(
            context: context,
            title: localizations.english,
            subtitle: 'English',
            locale: 'en',
            selected: currentLocale == 'en',
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
      onTap: () async {
        // 使用Provider更改语言
        await ref.read(localeProvider.notifier).changeLocale(locale);
        
        // 显示提示，但不需要重启应用
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.languageChanged),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
    );
  }
} 