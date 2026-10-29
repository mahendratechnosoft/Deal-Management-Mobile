import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_version_model.dart';
import '../presentation/widgets/app_update_dialog.dart';

class AppUpdateService {
  static const String androidPackageId = 'xpertbiz.crm.app';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=$androidPackageId';
  static const String playStoreMarketUri = 'market://details?id=$androidPackageId';

  static const String iOSAppId = '6827413847';
  static const String appStoreUrl =
      'https://apps.apple.com/in/app/xpertbiz-crm/id$iOSAppId';
  static const String iTunesLookupUrl =
      'https://itunes.apple.com/lookup?id=$iOSAppId';

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      },
    ),
  );

  /// Retrieves the installed app version from platform package info
  static Future<AppVersion> getCurrentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return AppVersion.parse(info.version);
    } catch (e) {
      log('⚠️ [AppUpdateService] Failed to get PackageInfo: $e');
      return AppVersion.parse('1.1.2');
    }
  }

  /// Fetches the live published version from Google Play or Apple App Store
  static Future<AppVersion?> fetchStoreVersion() async {
    try {
      if (kIsWeb) return null;

      if (Platform.isIOS) {
        return await _fetchIosAppStoreVersion();
      } else if (Platform.isAndroid) {
        return await _fetchAndroidPlayStoreVersion();
      }
    } catch (e) {
      log('⚠️ [AppUpdateService.fetchStoreVersion] Error: $e');
    }
    return null;
  }

  /// Fetches version from Apple iTunes lookup API
  static Future<AppVersion?> _fetchIosAppStoreVersion() async {
    try {
      final response = await _dio.get(iTunesLookupUrl);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map ? response.data : null;
        if (data != null && data['results'] is List && (data['results'] as List).isNotEmpty) {
          final first = (data['results'] as List).first;
          final versionStr = first['version']?.toString();
          if (versionStr != null && versionStr.isNotEmpty) {
            log('🍏 [AppUpdateService] Found App Store version: $versionStr');
            return AppVersion.parse(versionStr);
          }
        }
      }
    } catch (e) {
      log('⚠️ [AppUpdateService] Failed to fetch App Store version: $e');
    }
    return null;
  }

  /// Scrapes version from Google Play Store web details page
  static Future<AppVersion?> _fetchAndroidPlayStoreVersion() async {
    try {
      final url = 'https://play.google.com/store/apps/details?id=$androidPackageId&hl=en&gl=US';
      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.plain),
      );

      if (response.statusCode == 200 && response.data != null) {
        final html = response.data.toString();

        // 1. Primary AF_initDataCallback pattern: [[["1.1.2"]]]
        final regPrimary = RegExp(r'\[\[\["([0-9]+\.[0-9]+(?:\.[0-9]+)?)"\]\]');
        final matchPrimary = regPrimary.firstMatch(html);
        if (matchPrimary != null && matchPrimary.group(1) != null) {
          final v = matchPrimary.group(1)!;
          log('🤖 [AppUpdateService] Found Play Store version: $v');
          return AppVersion.parse(v);
        }

        // 2. Secondary fallback pattern: ["1.1.2"]
        final regSecondary = RegExp(r'\["([0-9]+\.[0-9]+(?:\.[0-9]+)?)"\]');
        final matchSecondary = regSecondary.firstMatch(html);
        if (matchSecondary != null && matchSecondary.group(1) != null) {
          final v = matchSecondary.group(1)!;
          log('🤖 [AppUpdateService] Found Play Store version (secondary): $v');
          return AppVersion.parse(v);
        }
      }
    } catch (e) {
      log('⚠️ [AppUpdateService] Failed to fetch Play Store version: $e');
    }
    return null;
  }

  /// Determines whether an update is available and whether it is major or minor:
  /// - Minor update: only PATCH version changed (e.g. 1.0.0 -> 1.0.1)
  /// - Major update: MINOR or MAJOR version changed (e.g. 1.0.0 -> 1.1.0, 1.1.1, 2.0.0)
  static UpdateType calculateUpdateType({
    required AppVersion currentVersion,
    required AppVersion storeVersion,
  }) {
    if (storeVersion <= currentVersion) {
      return UpdateType.none;
    }

    // Major or Minor version increment -> Major Update (Force update)
    if (storeVersion.major > currentVersion.major ||
        storeVersion.minor > currentVersion.minor) {
      return UpdateType.major;
    }

    // Only patch version increment -> Minor Update (Skip option allowed)
    if (storeVersion.patch > currentVersion.patch) {
      return UpdateType.minor;
    }

    return UpdateType.none;
  }

  /// Checks for an app update by comparing current version to store version
  static Future<AppUpdateInfo?> checkForUpdate({AppVersion? mockStoreVersion}) async {
    try {
      final currentVersion = await getCurrentVersion();
      final storeVersion = mockStoreVersion ?? await fetchStoreVersion();

      if (storeVersion == null) {
        log('ℹ️ [AppUpdateService] Could not resolve store version');
        return null;
      }

      final updateType = calculateUpdateType(
        currentVersion: currentVersion,
        storeVersion: storeVersion,
      );

      final String storeUrl;
      if (!kIsWeb && Platform.isIOS) {
        storeUrl = appStoreUrl;
      } else {
        storeUrl = playStoreUrl;
      }

      return AppUpdateInfo(
        currentVersion: currentVersion,
        storeVersion: storeVersion,
        updateType: updateType,
        storeUrl: storeUrl,
        releaseNotes: const [
          'Performance improvements',
          'system optimizations',
          'Bug fixes & stability refinements',
        ],
      );
    } catch (e) {
      log('⚠️ [AppUpdateService.checkForUpdate] Error: $e');
      return null;
    }
  }

  /// Launches the Google Play Store or Apple App Store page
  static Future<bool> openStore() async {
    try {
      if (!kIsWeb && Platform.isAndroid) {
        final marketUri = Uri.parse(playStoreMarketUri);
        if (await canLaunchUrl(marketUri)) {
          return await launchUrl(marketUri, mode: LaunchMode.externalApplication);
        }
        final webUri = Uri.parse(playStoreUrl);
        return await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else if (!kIsWeb && Platform.isIOS) {
        final iosUri = Uri.parse(appStoreUrl);
        return await launchUrl(iosUri, mode: LaunchMode.externalApplication);
      } else {
        final uri = Uri.parse(playStoreUrl);
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      log('❌ [AppUpdateService.openStore] Launch error: $e');
      return false;
    }
  }

  /// Checks for update and presents the appropriate dialog if an update exists.
  /// Returns true if an update dialog was shown.
  static Future<bool> showUpdateDialogIfNeeded(
    BuildContext context, {
    bool isManualCheck = false,
    AppVersion? mockStoreVersion,
  }) async {
    final info = await checkForUpdate(mockStoreVersion: mockStoreVersion);

    if (info == null || !info.hasUpdate) {
      if (isManualCheck) {
        final current = info?.currentVersion ?? await getCurrentVersion();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Xpertbiz is up to date (v$current)'),
              backgroundColor: const Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
      return false;
    }

    if (!context.mounted) return false;

    await showDialog(
      context: context,
      barrierDismissible: info.isMinor,
      builder: (_) => AppUpdateDialog(updateInfo: info),
    );

    return true;
  }

  /// For testing: Simulates a minor update dialog (e.g., 1.0.0 -> 1.0.1)
  static void simulateMinorUpdate(BuildContext context) {
    final info = AppUpdateInfo(
      currentVersion: const AppVersion(major: 1, minor: 0, patch: 0, raw: '1.0.0'),
      storeVersion: const AppVersion(major: 1, minor: 0, patch: 1, raw: '1.0.1'),
      updateType: UpdateType.minor,
      storeUrl: playStoreUrl,
      releaseNotes: const [
        'Performance improvements & faster load times',
        'Bug fixes for leave requests & attachments',
        'UI refinements across dropdowns and dialogs',
      ],
    );
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AppUpdateDialog(updateInfo: info),
    );
  }

  /// For testing: Simulates a major update dialog (e.g., 1.0.0 -> 1.1.1 or 2.0.0)
  static void simulateMajorUpdate(BuildContext context, {String target = '1.1.1'}) {
    final info = AppUpdateInfo(
      currentVersion: const AppVersion(major: 1, minor: 0, patch: 0, raw: '1.0.0'),
      storeVersion: AppVersion.parse(target),
      updateType: UpdateType.major,
      storeUrl: playStoreUrl,
      releaseNotes: const [
        'Important security & architecture upgrades',
        'New Leave Request & Approvals system',
        'Critical bug fixes and API protocol updates',
      ],
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AppUpdateDialog(updateInfo: info),
    );
  }
}
