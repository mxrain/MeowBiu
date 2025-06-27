import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import '../models/release.dart';
import '../models/version.dart';
import 'preference_service.dart';

/// 更新服务，负责检查更新、下载和安装APK
class UpdateService {
  static const String _apiUrl = 'https://api.github.com/repos/mxrain/miaowang/releases';
  static final Dio _dio = Dio();
  static CancelToken? _cancelToken;

  /// 检查更新
  /// 
  /// 返回新的发布版本，如果没有更新则返回null
  static Future<Release?> checkForUpdate() async {
    try {
      // 获取偏好设置
      final prefService = PreferenceService();
      await prefService.init();
      final updateChannel = prefService.getUpdateChannel();
      
      // 获取当前版本
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = Version.parse(packageInfo.version);
      
      // 获取远程发布列表
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode != 200) {
        throw Exception('获取发布信息失败: ${response.statusCode}');
      }
      
      // 解析发布列表
      final releases = Release.parseReleases(response.body);
      
      // 根据更新频道筛选
      final filteredReleases = updateChannel == UpdateChannel.stable
          ? releases.where((r) => !r.preRelease).toList()
          : releases;
      
      // 找到最新版本
      if (filteredReleases.isEmpty) return null;
      final latestRelease = filteredReleases.first;
      
      // 解析版本号并比较
      final latestVersion = Version.parse(
          latestRelease.tagName.replaceFirst('v', ''));
      
      // 记录检查时间
      await prefService.setLastCheckUpdateTime(DateTime.now());
      
      // 只有当新版本大于当前版本时才返回
      return currentVersion.compareTo(latestVersion) < 0 ? latestRelease : null;
    } catch (e) {
      debugPrint('检查更新失败: $e');
      return null;
    }
  }

  /// 下载APK文件
  /// 
  /// [release] 发布信息
  /// [onProgress] 下载进度回调，返回0.0-1.0的进度值
  /// [onError] 错误回调
  /// 返回下载的文件路径，下载失败返回null
  static Future<String?> downloadApk({
    required Release release,
    Function(double)? onProgress,
    Function(String)? onError,
  }) async {
    if (!release.isDownloadable) {
      onError?.call('没有可下载的APK文件');
      return null;
    }

    try {
      // 检查并请求存储权限
      final permissionStatus = await Permission.storage.request();
      if (!permissionStatus.isGranted) {
        onError?.call('需要存储权限才能下载APK文件');
        return null;
      }
      
      // 获取适合当前设备的APK
      final asset = _getBestAssetForDevice(release.assets);
      if (asset == null) {
        onError?.call('未找到适合当前设备的APK文件');
        return null;
      }
      
      // 创建下载目录
      final downloadDir = await getExternalStorageDirectory();
      if (downloadDir == null) {
        onError?.call('无法获取下载目录');
        return null;
      }
      
      // 创建下载目标路径
      final filePath = '${downloadDir.path}/${asset.name}';
      final file = File(filePath);
      
      // 创建取消令牌
      _cancelToken = CancelToken();
      
      // 下载文件
      await _dio.download(
        asset.downloadUrl,
        filePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress?.call(progress);
          }
        },
      );
      
      return file.existsSync() ? filePath : null;
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        onError?.call('下载已取消');
      } else {
        onError?.call('下载APK失败: $e');
      }
      return null;
    }
  }

  /// 取消当前下载
  static void cancelDownload() {
    _cancelToken?.cancel('用户取消下载');
    _cancelToken = null;
  }

  /// 安装APK
  /// 
  /// [filePath] APK文件路径
  /// 返回是否成功调用安装程序
  static Future<bool> installApk(String filePath) async {
    try {
      // Android安装APK
      if (Platform.isAndroid) {
        // 请求安装未知来源应用权限（Android 8.0+需要）
        if (await Permission.requestInstallPackages.request().isGranted) {
          final result = await OpenFile.open(filePath);
          return result.type == ResultType.done;
        } else {
          debugPrint('没有安装权限');
          return false;
        }
      } 
      // iOS跳转到App Store
      else if (Platform.isIOS) {
        const appStoreId = '你的App Store ID';
        final url = 'https://apps.apple.com/app/id$appStoreId';
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          return await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
      
      return false;
    } catch (e) {
      debugPrint('安装APK失败: $e');
      return false;
    }
  }

  /// 获取最适合当前设备的APK资源
  static ReleaseAsset? _getBestAssetForDevice(List<ReleaseAsset> assets) {
    // 只选择APK文件
    final apkAssets = assets.where((asset) => asset.isApkFile).toList();
    if (apkAssets.isEmpty) return null;
    
    // 获取设备架构信息（简单实现，实际可能需要更复杂的逻辑）
    final preferredArch = _getPreferredArchitecture();
    
    // 寻找匹配架构的APK
    for (final arch in preferredArch) {
      for (final asset in apkAssets) {
        final assetArch = asset.getArchitecture();
        if (assetArch == arch) {
          return asset;
        }
      }
    }
    
    // 如果没有找到匹配架构的APK，返回第一个APK
    return apkAssets.first;
  }

  /// 获取优先架构顺序
  static List<String> _getPreferredArchitecture() {
    // 优先级从高到低排列
    return [
      'arm64-v8a',
      'armeabi-v7a',
      'x86_64',
      'x86',
    ];
  }
} 