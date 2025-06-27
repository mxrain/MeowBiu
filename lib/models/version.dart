/// 版本比较类，支持语义化版本比较
class Version implements Comparable<Version> {
  final int major;
  final int minor;
  final int patch;
  final String? preRelease;
  final int? buildNumber;  // 添加构建号

  const Version(this.major, this.minor, this.patch, [this.preRelease, this.buildNumber]);

  /// 从字符串解析版本号
  static Version parse(String versionString) {
    // 移除版本号前的'v'前缀（如果有）
    if (versionString.startsWith('v')) {
      versionString = versionString.substring(1);
    }

    // 处理Flutter版本号格式（如1.2.3+4，提取构建号部分）
    int? buildNumber;
    if (versionString.contains('+')) {
      final parts = versionString.split('+');
      versionString = parts[0];
      try {
        buildNumber = int.parse(parts[1]);
      } catch (e) {
        // 忽略构建号解析错误
      }
    }

    // 分离预发布部分
    String? preRelease;
    if (versionString.contains('-')) {
      final parts = versionString.split('-');
      versionString = parts[0];
      preRelease = parts[1];
    }

    // 分割版本号
    final parts = versionString.split('.');
    if (parts.length < 3) {
      throw FormatException('Invalid version format: $versionString');
    }

    try {
      final major = int.parse(parts[0]);
      final minor = int.parse(parts[1]);
      final patch = int.parse(parts[2]);

      return Version(major, minor, patch, preRelease, buildNumber);
    } catch (e) {
      throw FormatException('Failed to parse version: $versionString');
    }
  }

  /// 判断是否为预发布版本
  bool get isPreRelease => preRelease != null;

  @override
  int compareTo(Version other) {
    // 比较主版本号
    int result = major.compareTo(other.major);
    if (result != 0) return result;

    // 比较次版本号
    result = minor.compareTo(other.minor);
    if (result != 0) return result;

    // 比较修订版本号
    result = patch.compareTo(other.patch);
    if (result != 0) return result;

    // 比较预发布标识
    // 没有预发布标识的版本高于有预发布标识的版本
    if (preRelease == null && other.preRelease != null) return 1;
    if (preRelease != null && other.preRelease == null) return -1;
    if (preRelease != null && other.preRelease != null) {
      result = preRelease!.compareTo(other.preRelease!);
      if (result != 0) return result;
    }

    // 如果语义版本相同，比较构建号（如果有）
    if (buildNumber != null && other.buildNumber != null) {
      return buildNumber!.compareTo(other.buildNumber!);
    } else if (buildNumber != null) {
      return 1;  // 有构建号的版本高于没有构建号的版本
    } else if (other.buildNumber != null) {
      return -1;  // 没有构建号的版本低于有构建号的版本
    }
    
    return 0;  // 完全相同
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Version) return false;

    return major == other.major &&
        minor == other.minor &&
        patch == other.patch &&
        preRelease == other.preRelease &&
        buildNumber == other.buildNumber;
  }

  @override
  int get hashCode => Object.hash(major, minor, patch, preRelease, buildNumber);

  @override
  String toString() {
    final version = '$major.$minor.$patch';
    final preReleaseStr = preRelease == null ? '' : '-$preRelease';
    final buildNumberStr = buildNumber == null ? '' : '+$buildNumber';
    return '$version$preReleaseStr$buildNumberStr';
  }

  /// 创建完整版本号字符串（包含v前缀）
  String toFullString() => 'v${toString()}';
}