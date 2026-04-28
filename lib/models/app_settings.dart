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