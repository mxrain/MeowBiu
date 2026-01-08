import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// 版本更新信息
class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String releaseNotes;
  final DateTime publishedAt;
  final bool isPrerelease;

  UpdateInfo({
    required this.version,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.publishedAt,
    this.isPrerelease = false,
  });

  factory UpdateInfo.fromGitHubRelease(Map<String, dynamic> json) {
    // 根据平台选择下载链接
    String downloadUrl = '';
    final assets = json['assets'] as List<dynamic>? ?? [];
    
    for (final asset in assets) {
      final name = asset['name'] as String? ?? '';
      if (Platform.isWindows && name.endsWith('.exe')) {
        downloadUrl = asset['browser_download_url'];
        break;
      } else if (Platform.isAndroid && name.endsWith('.apk')) {
        downloadUrl = asset['browser_download_url'];
        break;
      } else if (Platform.isMacOS && (name.endsWith('.dmg') || name.endsWith('.zip'))) {
        downloadUrl = asset['browser_download_url'];
        break;
      } else if (Platform.isLinux && name.endsWith('.tar.gz')) {
        downloadUrl = asset['browser_download_url'];
        break;
      }
    }

    return UpdateInfo(
      version: (json['tag_name'] as String? ?? '').replaceFirst('v', ''),
      downloadUrl: downloadUrl,
      releaseNotes: json['body'] as String? ?? '',
      publishedAt: DateTime.parse(json['published_at'] as String),
      isPrerelease: json['prerelease'] as bool? ?? false,
    );
  }
}

/// 版本比较结果
enum VersionCompareResult {
  newer,    // 有新版本
  same,     // 相同版本
  older,    // 当前版本更新（开发版）
}

/// 自动更新服务
class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // GitHub 仓库信息
  static const String _owner = 'mxrain';
  static const String _repo = 'miaowang';
  static const String _apiBase = 'https://api.github.com';

  /// 检查更新
  Future<UpdateInfo?> checkForUpdate({bool includePrerelease = false}) async {
    try {
      final response = await _dio.get(
        '$_apiBase/repos/$_owner/$_repo/releases',
        options: Options(headers: {'Accept': 'application/vnd.github.v3+json'}),
      );

      if (response.statusCode != 200) return null;

      final releases = response.data as List<dynamic>;
      if (releases.isEmpty) return null;

      // 找到最新的正式版或预发布版
      Map<String, dynamic>? latestRelease;
      for (final release in releases) {
        final isPrerelease = release['prerelease'] as bool? ?? false;
        if (!isPrerelease || includePrerelease) {
          latestRelease = release;
          break;
        }
      }

      if (latestRelease == null) return null;

      final updateInfo = UpdateInfo.fromGitHubRelease(latestRelease);
      
      // 比较版本
      final currentVersion = await _getCurrentVersion();
      final compareResult = _compareVersions(currentVersion, updateInfo.version);
      
      if (compareResult == VersionCompareResult.newer) {
        return updateInfo;
      }
      
      return null;
    } catch (e) {
      debugPrint('检查更新失败: $e');
      return null;
    }
  }

  /// 获取当前版本
  Future<String> _getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  /// 比较版本号
  VersionCompareResult _compareVersions(String current, String remote) {
    final currentParts = current.split('.').map(int.parse).toList();
    final remoteParts = remote.split('.').map(int.parse).toList();

    // 补齐版本号长度
    while (currentParts.length < 3) currentParts.add(0);
    while (remoteParts.length < 3) remoteParts.add(0);

    for (int i = 0; i < 3; i++) {
      if (remoteParts[i] > currentParts[i]) {
        return VersionCompareResult.newer;
      } else if (remoteParts[i] < currentParts[i]) {
        return VersionCompareResult.older;
      }
    }
    
    return VersionCompareResult.same;
  }

  /// 打开下载页面
  Future<void> openDownloadPage(UpdateInfo updateInfo) async {
    final Uri url;
    
    if (updateInfo.downloadUrl.isNotEmpty) {
      url = Uri.parse(updateInfo.downloadUrl);
    } else {
      // 回退到 Release 页面
      url = Uri.parse('https://github.com/$_owner/$_repo/releases/latest');
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// 获取 Release 页面 URL
  String get releasesUrl => 'https://github.com/$_owner/$_repo/releases';
}
