import 'package:flutter/material.dart';

class AppSettings {
  final ThemeMode themeMode;
  final double fontScale;
  final bool kidModeEnabled;
  final bool notificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool smsAlertsEnabled;
  final bool locationSharingEnabled;
  final bool emergencyBroadcastEnabled;
  final bool screenTimeLimitEnabled;
  final int screenTimeLimitMinutes;
  final int bedtimeHour;
  final int bedtimeMinute;
  final bool contentFilterEnabled;
  final bool safeZonesEnabled;
  final double displayScale;

  // New settings
  final bool twoFactorEnabled;
  final bool biometricEnabled;
  final bool readReceiptsEnabled;
  final bool typingIndicatorsEnabled;
  final bool onlineStatusEnabled;
  final bool autoDownloadMedia;
  final bool highQualityImages;
  final bool autoPlayVideos;
  final bool voiceMessagesEnabled;
  final bool dataSaverMode;
  final bool boldTextEnabled;
  final bool highContrastEnabled;
  final bool reduceMotionEnabled;
  final double accessibilityTextScale;
  final String profileVisibility;
  final bool activityStatusEnabled;
  final bool locationHistoryEnabled;
  final bool soundEnabled;
  final bool vibrateEnabled;

  AppSettings({
    this.themeMode = ThemeMode.system,
    this.fontScale = 1.0,
    this.kidModeEnabled = false,
    this.notificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.smsAlertsEnabled = false,
    this.locationSharingEnabled = false,
    this.emergencyBroadcastEnabled = true,
    this.screenTimeLimitEnabled = true,
    this.screenTimeLimitMinutes = 120,
    this.bedtimeHour = 21,
    this.bedtimeMinute = 0,
    this.contentFilterEnabled = true,
    this.safeZonesEnabled = false,
    this.displayScale = 1.0,
    this.twoFactorEnabled = false,
    this.biometricEnabled = false,
    this.readReceiptsEnabled = true,
    this.typingIndicatorsEnabled = true,
    this.onlineStatusEnabled = true,
    this.autoDownloadMedia = true,
    this.highQualityImages = false,
    this.autoPlayVideos = false,
    this.voiceMessagesEnabled = true,
    this.dataSaverMode = false,
    this.boldTextEnabled = false,
    this.highContrastEnabled = false,
    this.reduceMotionEnabled = false,
    this.accessibilityTextScale = 1.0,
    this.profileVisibility = 'Family Only',
    this.activityStatusEnabled = true,
    this.locationHistoryEnabled = false,
    this.soundEnabled = true,
    this.vibrateEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.index,
      'fontScale': fontScale,
      'kidModeEnabled': kidModeEnabled,
      'notificationsEnabled': notificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'smsAlertsEnabled': smsAlertsEnabled,
      'locationSharingEnabled': locationSharingEnabled,
      'emergencyBroadcastEnabled': emergencyBroadcastEnabled,
      'screenTimeLimitEnabled': screenTimeLimitEnabled,
      'screenTimeLimitMinutes': screenTimeLimitMinutes,
      'bedtimeHour': bedtimeHour,
      'bedtimeMinute': bedtimeMinute,
      'contentFilterEnabled': contentFilterEnabled,
      'safeZonesEnabled': safeZonesEnabled,
      'displayScale': displayScale,
      'twoFactorEnabled': twoFactorEnabled,
      'biometricEnabled': biometricEnabled,
      'readReceiptsEnabled': readReceiptsEnabled,
      'typingIndicatorsEnabled': typingIndicatorsEnabled,
      'onlineStatusEnabled': onlineStatusEnabled,
      'autoDownloadMedia': autoDownloadMedia,
      'highQualityImages': highQualityImages,
      'autoPlayVideos': autoPlayVideos,
      'voiceMessagesEnabled': voiceMessagesEnabled,
      'dataSaverMode': dataSaverMode,
      'boldTextEnabled': boldTextEnabled,
      'highContrastEnabled': highContrastEnabled,
      'reduceMotionEnabled': reduceMotionEnabled,
      'accessibilityTextScale': accessibilityTextScale,
      'profileVisibility': profileVisibility,
      'activityStatusEnabled': activityStatusEnabled,
      'locationHistoryEnabled': locationHistoryEnabled,
      'soundEnabled': soundEnabled,
      'vibrateEnabled': vibrateEnabled,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      themeMode: ThemeMode.values[map['themeMode'] as int? ?? 0],
      fontScale: map['fontScale'] as double? ?? 1.0,
      kidModeEnabled: map['kidModeEnabled'] as bool? ?? false,
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      emailNotificationsEnabled: map['emailNotificationsEnabled'] as bool? ?? true,
      smsAlertsEnabled: map['smsAlertsEnabled'] as bool? ?? false,
      locationSharingEnabled: map['locationSharingEnabled'] as bool? ?? false,
      emergencyBroadcastEnabled: map['emergencyBroadcastEnabled'] as bool? ?? true,
      screenTimeLimitEnabled: map['screenTimeLimitEnabled'] as bool? ?? true,
      screenTimeLimitMinutes: map['screenTimeLimitMinutes'] as int? ?? 120,
      bedtimeHour: map['bedtimeHour'] as int? ?? 21,
      bedtimeMinute: map['bedtimeMinute'] as int? ?? 0,
      contentFilterEnabled: map['contentFilterEnabled'] as bool? ?? true,
      safeZonesEnabled: map['safeZonesEnabled'] as bool? ?? false,
      displayScale: map['displayScale'] as double? ?? 1.0,
      twoFactorEnabled: map['twoFactorEnabled'] as bool? ?? false,
      biometricEnabled: map['biometricEnabled'] as bool? ?? false,
      readReceiptsEnabled: map['readReceiptsEnabled'] as bool? ?? true,
      typingIndicatorsEnabled: map['typingIndicatorsEnabled'] as bool? ?? true,
      onlineStatusEnabled: map['onlineStatusEnabled'] as bool? ?? true,
      autoDownloadMedia: map['autoDownloadMedia'] as bool? ?? true,
      highQualityImages: map['highQualityImages'] as bool? ?? false,
      autoPlayVideos: map['autoPlayVideos'] as bool? ?? false,
      voiceMessagesEnabled: map['voiceMessagesEnabled'] as bool? ?? true,
      dataSaverMode: map['dataSaverMode'] as bool? ?? false,
      boldTextEnabled: map['boldTextEnabled'] as bool? ?? false,
      highContrastEnabled: map['highContrastEnabled'] as bool? ?? false,
      reduceMotionEnabled: map['reduceMotionEnabled'] as bool? ?? false,
      accessibilityTextScale: map['accessibilityTextScale'] as double? ?? 1.0,
      profileVisibility: map['profileVisibility'] as String? ?? 'Family Only',
      activityStatusEnabled: map['activityStatusEnabled'] as bool? ?? true,
      locationHistoryEnabled: map['locationHistoryEnabled'] as bool? ?? false,
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      vibrateEnabled: map['vibrateEnabled'] as bool? ?? true,
    );
  }

  AppSettings copyWith({
    ThemeMode? themeMode,
    double? fontScale,
    bool? kidModeEnabled,
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? smsAlertsEnabled,
    bool? locationSharingEnabled,
    bool? emergencyBroadcastEnabled,
    bool? screenTimeLimitEnabled,
    int? screenTimeLimitMinutes,
    int? bedtimeHour,
    int? bedtimeMinute,
    bool? contentFilterEnabled,
    bool? safeZonesEnabled,
    double? displayScale,
    bool? twoFactorEnabled,
    bool? biometricEnabled,
    bool? readReceiptsEnabled,
    bool? typingIndicatorsEnabled,
    bool? onlineStatusEnabled,
    bool? autoDownloadMedia,
    bool? highQualityImages,
    bool? autoPlayVideos,
    bool? voiceMessagesEnabled,
    bool? dataSaverMode,
    bool? boldTextEnabled,
    bool? highContrastEnabled,
    bool? reduceMotionEnabled,
    double? accessibilityTextScale,
    String? profileVisibility,
    bool? activityStatusEnabled,
    bool? locationHistoryEnabled,
    bool? soundEnabled,
    bool? vibrateEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      fontScale: fontScale ?? this.fontScale,
      kidModeEnabled: kidModeEnabled ?? this.kidModeEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      smsAlertsEnabled: smsAlertsEnabled ?? this.smsAlertsEnabled,
      locationSharingEnabled: locationSharingEnabled ?? this.locationSharingEnabled,
      emergencyBroadcastEnabled: emergencyBroadcastEnabled ?? this.emergencyBroadcastEnabled,
      screenTimeLimitEnabled: screenTimeLimitEnabled ?? this.screenTimeLimitEnabled,
      screenTimeLimitMinutes: screenTimeLimitMinutes ?? this.screenTimeLimitMinutes,
      bedtimeHour: bedtimeHour ?? this.bedtimeHour,
      bedtimeMinute: bedtimeMinute ?? this.bedtimeMinute,
      contentFilterEnabled: contentFilterEnabled ?? this.contentFilterEnabled,
      safeZonesEnabled: safeZonesEnabled ?? this.safeZonesEnabled,
      displayScale: displayScale ?? this.displayScale,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      readReceiptsEnabled: readReceiptsEnabled ?? this.readReceiptsEnabled,
      typingIndicatorsEnabled: typingIndicatorsEnabled ?? this.typingIndicatorsEnabled,
      onlineStatusEnabled: onlineStatusEnabled ?? this.onlineStatusEnabled,
      autoDownloadMedia: autoDownloadMedia ?? this.autoDownloadMedia,
      highQualityImages: highQualityImages ?? this.highQualityImages,
      autoPlayVideos: autoPlayVideos ?? this.autoPlayVideos,
      voiceMessagesEnabled: voiceMessagesEnabled ?? this.voiceMessagesEnabled,
      dataSaverMode: dataSaverMode ?? this.dataSaverMode,
      boldTextEnabled: boldTextEnabled ?? this.boldTextEnabled,
      highContrastEnabled: highContrastEnabled ?? this.highContrastEnabled,
      reduceMotionEnabled: reduceMotionEnabled ?? this.reduceMotionEnabled,
      accessibilityTextScale: accessibilityTextScale ?? this.accessibilityTextScale,
      profileVisibility: profileVisibility ?? this.profileVisibility,
      activityStatusEnabled: activityStatusEnabled ?? this.activityStatusEnabled,
      locationHistoryEnabled: locationHistoryEnabled ?? this.locationHistoryEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrateEnabled: vibrateEnabled ?? this.vibrateEnabled,
    );
  }

  String get formattedBedtime {
    final hour = bedtimeHour % 12 == 0 ? 12 : bedtimeHour % 12;
    final period = bedtimeHour >= 12 ? 'PM' : 'AM';
    return '$hour:${bedtimeMinute.toString().padLeft(2, '0')} $period';
  }

  String get formattedScreenTime {
    final hours = screenTimeLimitMinutes ~/ 60;
    final minutes = screenTimeLimitMinutes % 60;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }
}
