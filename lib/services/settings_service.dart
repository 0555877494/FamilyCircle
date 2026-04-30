import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsService {
  static const _keyThemeMode = 'themeMode';
  static const _keyFontScale = 'fontScale';
  static const _keyKidMode = 'kidMode';
  static const _keyNotifications = 'notifications';
  static const _keyEmailNotifications = 'emailNotifications';
  static const _keySmsAlerts = 'smsAlerts';
  static const _keyLocationSharing = 'locationSharing';
  static const _keyEmergencyBroadcast = 'emergencyBroadcast';
  static const _keyScreenTimeLimit = 'screenTimeLimit';
  static const _keyScreenTimeMinutes = 'screenTimeMinutes';
  static const _keyBedtimeHour = 'bedtimeHour';
  static const _keyBedtimeMinute = 'bedtimeMinute';
  static const _keyContentFilter = 'contentFilter';
  static const _keySafeZones = 'safeZones';
  static const _keyDisplayScale = 'displayScale';
  static const _keyTwoFactor = 'twoFactor';
  static const _keyBiometric = 'biometric';
  static const _keyReadReceipts = 'readReceipts';
  static const _keyTypingIndicators = 'typingIndicators';
  static const _keyOnlineStatus = 'onlineStatus';
  static const _keyAutoDownload = 'autoDownload';
  static const _keyHighQualityImages = 'highQualityImages';
  static const _keyAutoPlayVideos = 'autoPlayVideos';
  static const _keyVoiceMessages = 'voiceMessages';
  static const _keyDataSaver = 'dataSaver';
  static const _keyBoldText = 'boldText';
  static const _keyHighContrast = 'highContrast';
  static const _keyReduceMotion = 'reduceMotion';
  static const _keyAccessibilityTextScale = 'accessibilityTextScale';
  static const _keyProfileVisibility = 'profileVisibility';
  static const _keyActivityStatus = 'activityStatus';
  static const _keyLocationHistory = 'locationHistory';

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    return AppSettings(
      themeMode: ThemeMode.values[prefs.getInt(_keyThemeMode) ?? 0],
      fontScale: prefs.getDouble(_keyFontScale) ?? 1.0,
      kidModeEnabled: prefs.getBool(_keyKidMode) ?? false,
      notificationsEnabled: prefs.getBool(_keyNotifications) ?? true,
      emailNotificationsEnabled: prefs.getBool(_keyEmailNotifications) ?? true,
      smsAlertsEnabled: prefs.getBool(_keySmsAlerts) ?? false,
      locationSharingEnabled: prefs.getBool(_keyLocationSharing) ?? false,
      emergencyBroadcastEnabled: prefs.getBool(_keyEmergencyBroadcast) ?? true,
      screenTimeLimitEnabled: prefs.getBool(_keyScreenTimeLimit) ?? true,
      screenTimeLimitMinutes: prefs.getInt(_keyScreenTimeMinutes) ?? 120,
      bedtimeHour: prefs.getInt(_keyBedtimeHour) ?? 21,
      bedtimeMinute: prefs.getInt(_keyBedtimeMinute) ?? 0,
      contentFilterEnabled: prefs.getBool(_keyContentFilter) ?? true,
      safeZonesEnabled: prefs.getBool(_keySafeZones) ?? false,
      displayScale: prefs.getDouble(_keyDisplayScale) ?? 1.0,
      twoFactorEnabled: prefs.getBool(_keyTwoFactor) ?? false,
      biometricEnabled: prefs.getBool(_keyBiometric) ?? false,
      readReceiptsEnabled: prefs.getBool(_keyReadReceipts) ?? true,
      typingIndicatorsEnabled: prefs.getBool(_keyTypingIndicators) ?? true,
      onlineStatusEnabled: prefs.getBool(_keyOnlineStatus) ?? true,
      autoDownloadMedia: prefs.getBool(_keyAutoDownload) ?? true,
      highQualityImages: prefs.getBool(_keyHighQualityImages) ?? false,
      autoPlayVideos: prefs.getBool(_keyAutoPlayVideos) ?? false,
      voiceMessagesEnabled: prefs.getBool(_keyVoiceMessages) ?? true,
      dataSaverMode: prefs.getBool(_keyDataSaver) ?? false,
      boldTextEnabled: prefs.getBool(_keyBoldText) ?? false,
      highContrastEnabled: prefs.getBool(_keyHighContrast) ?? false,
      reduceMotionEnabled: prefs.getBool(_keyReduceMotion) ?? false,
      accessibilityTextScale: prefs.getDouble(_keyAccessibilityTextScale) ?? 1.0,
      profileVisibility: prefs.getString(_keyProfileVisibility) ?? 'Family Only',
      activityStatusEnabled: prefs.getBool(_keyActivityStatus) ?? true,
      locationHistoryEnabled: prefs.getBool(_keyLocationHistory) ?? false,
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt(_keyThemeMode, settings.themeMode.index);
    await prefs.setDouble(_keyFontScale, settings.fontScale);
    await prefs.setBool(_keyKidMode, settings.kidModeEnabled);
    await prefs.setBool(_keyNotifications, settings.notificationsEnabled);
    await prefs.setBool(_keyEmailNotifications, settings.emailNotificationsEnabled);
    await prefs.setBool(_keySmsAlerts, settings.smsAlertsEnabled);
    await prefs.setBool(_keyLocationSharing, settings.locationSharingEnabled);
    await prefs.setBool(_keyEmergencyBroadcast, settings.emergencyBroadcastEnabled);
    await prefs.setBool(_keyScreenTimeLimit, settings.screenTimeLimitEnabled);
    await prefs.setInt(_keyScreenTimeMinutes, settings.screenTimeLimitMinutes);
    await prefs.setInt(_keyBedtimeHour, settings.bedtimeHour);
    await prefs.setInt(_keyBedtimeMinute, settings.bedtimeMinute);
    await prefs.setBool(_keyContentFilter, settings.contentFilterEnabled);
    await prefs.setBool(_keySafeZones, settings.safeZonesEnabled);
    await prefs.setDouble(_keyDisplayScale, settings.displayScale);
    await prefs.setBool(_keyTwoFactor, settings.twoFactorEnabled);
    await prefs.setBool(_keyBiometric, settings.biometricEnabled);
    await prefs.setBool(_keyReadReceipts, settings.readReceiptsEnabled);
    await prefs.setBool(_keyTypingIndicators, settings.typingIndicatorsEnabled);
    await prefs.setBool(_keyOnlineStatus, settings.onlineStatusEnabled);
    await prefs.setBool(_keyAutoDownload, settings.autoDownloadMedia);
    await prefs.setBool(_keyHighQualityImages, settings.highQualityImages);
    await prefs.setBool(_keyAutoPlayVideos, settings.autoPlayVideos);
    await prefs.setBool(_keyVoiceMessages, settings.voiceMessagesEnabled);
    await prefs.setBool(_keyDataSaver, settings.dataSaverMode);
    await prefs.setBool(_keyBoldText, settings.boldTextEnabled);
    await prefs.setBool(_keyHighContrast, settings.highContrastEnabled);
    await prefs.setBool(_keyReduceMotion, settings.reduceMotionEnabled);
    await prefs.setDouble(_keyAccessibilityTextScale, settings.accessibilityTextScale);
    await prefs.setString(_keyProfileVisibility, settings.profileVisibility);
    await prefs.setBool(_keyActivityStatus, settings.activityStatusEnabled);
    await prefs.setBool(_keyLocationHistory, settings.locationHistoryEnabled);
  }

  Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
