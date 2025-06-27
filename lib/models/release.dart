import 'dart:convert';

/// GitHub发布信息模型
class Release {
  /// 发布的标题
  final String name;
  
  /// 标签名称（版本号）
  final String tagName;
  
  /// 发布描述（更新日志）
  final String body;
  
  /// 是否为预发布版本
  final bool preRelease;
  
  /// 发布日期
  final DateTime publishedAt;
  
  /// 下载链接
  final List<ReleaseAsset> assets;

  const Release({
    required this.name,
    required this.tagName,
    required this.body,
    required this.preRelease,
    required this.publishedAt,
    required this.assets,
  });

  /// 从JSON映射创建发布信息
  factory Release.fromJson(Map<String, dynamic> json) {
    final assets = <ReleaseAsset>[];
    if (json['assets'] != null) {
      for (var item in json['assets']) {
        assets.add(ReleaseAsset.fromJson(item));
      }
    }

    return Release(
      name: json['name'] ?? '',
      tagName: json['tag_name'] ?? '',
      body: json['body'] ?? '',
      preRelease: json['prerelease'] ?? false,
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'])
          : DateTime.now(),
      assets: assets,
    );
  }

  /// 从GitHub API响应创建发布信息列表
  static List<Release> parseReleases(String responseBody) {
    final parsed = jsonDecode(responseBody) as List;
    return parsed.map((json) => Release.fromJson(json)).toList();
  }

  /// 判断是否为可下载的发布版本
  bool get isDownloadable => assets.isNotEmpty;
}

/// GitHub发布资源模型（APK文件）
class ReleaseAsset {
  /// 资源ID
  final int id;
  
  /// 资源名称（文件名）
  final String name;
  
  /// 下载链接
  final String downloadUrl;
  
  /// 文件大小（字节）
  final int size;
  
  /// 文件类型
  final String contentType;

  const ReleaseAsset({
    required this.id,
    required this.name,
    required this.downloadUrl,
    required this.size,
    required this.contentType,
  });

  /// 从JSON映射创建资源信息
  factory ReleaseAsset.fromJson(Map<String, dynamic> json) {
    return ReleaseAsset(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      downloadUrl: json['browser_download_url'] ?? '',
      size: json['size'] ?? 0,
      contentType: json['content_type'] ?? '',
    );
  }

  /// 是否为APK文件
  bool get isApkFile => name.toLowerCase().endsWith('.apk');
  
  /// 获取CPU架构标识
  String? getArchitecture() {
    final lowercaseName = name.toLowerCase();
    if (lowercaseName.contains('arm64-v8a') || lowercaseName.contains('arm64')) {
      return 'arm64-v8a';
    } else if (lowercaseName.contains('armeabi-v7a') || lowercaseName.contains('arm')) {
      return 'armeabi-v7a';
    } else if (lowercaseName.contains('x86_64')) {
      return 'x86_64';
    } else if (lowercaseName.contains('x86')) {
      return 'x86';
    }
    return null;
  }
} 