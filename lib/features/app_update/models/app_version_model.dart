class AppVersion implements Comparable<AppVersion> {
  final int major;
  final int minor;
  final int patch;
  final String raw;

  const AppVersion({
    required this.major,
    required this.minor,
    required this.patch,
    required this.raw,
  });

  /// Parses a version string like "1.0.0", "1.1.2+8", "1.0", "v2.0.1"
  factory AppVersion.parse(String versionString) {
    if (versionString.trim().isEmpty) {
      return const AppVersion(major: 0, minor: 0, patch: 0, raw: '0.0.0');
    }

    // Clean prefix 'v' or 'V' and strip build suffix after '+' or '-'
    String clean = versionString.trim();
    if (clean.toLowerCase().startsWith('v')) {
      clean = clean.substring(1).trim();
    }
    clean = clean.split('+').first.split('-').first.trim();

    final parts = clean.split('.');
    final major = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minor = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final patch = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;

    return AppVersion(
      major: major,
      minor: minor,
      patch: patch,
      raw: clean,
    );
  }

  @override
  int compareTo(AppVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    return patch.compareTo(other.patch);
  }

  bool operator >(AppVersion other) => compareTo(other) > 0;
  bool operator <(AppVersion other) => compareTo(other) < 0;
  bool operator >=(AppVersion other) => compareTo(other) >= 0;
  bool operator <=(AppVersion other) => compareTo(other) <= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppVersion &&
          major == other.major &&
          minor == other.minor &&
          patch == other.patch;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}

enum UpdateType {
  none,
  minor,
  major,
}

class AppUpdateInfo {
  final AppVersion currentVersion;
  final AppVersion storeVersion;
  final UpdateType updateType;
  final String storeUrl;
  final List<String> releaseNotes;

  const AppUpdateInfo({
    required this.currentVersion,
    required this.storeVersion,
    required this.updateType,
    required this.storeUrl,
    this.releaseNotes = const [],
  });

  bool get hasUpdate => updateType != UpdateType.none;
  bool get isMajor => updateType == UpdateType.major;
  bool get isMinor => updateType == UpdateType.minor;
}
