class ParentalSettings {
  final bool screenTimeEnabled;
  final int screenTimeLimitMinutes;
  final int bedtimeHour;
  final int bedtimeMinute;
  final bool contentFilterEnabled;
  final bool locationSharingEnabled;
  final bool emergencyBroadcastEnabled;

  ParentalSettings({
    this.screenTimeEnabled = true,
    this.screenTimeLimitMinutes = 120,
    this.bedtimeHour = 21,
    this.bedtimeMinute = 0,
    this.contentFilterEnabled = true,
    this.locationSharingEnabled = false,
    this.emergencyBroadcastEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'screenTimeEnabled': screenTimeEnabled,
      'screenTimeLimitMinutes': screenTimeLimitMinutes,
      'bedtimeHour': bedtimeHour,
      'bedtimeMinute': bedtimeMinute,
      'contentFilterEnabled': contentFilterEnabled,
      'locationSharingEnabled': locationSharingEnabled,
      'emergencyBroadcastEnabled': emergencyBroadcastEnabled,
    };
  }

  factory ParentalSettings.fromMap(Map<String, dynamic> map) {
    return ParentalSettings(
      screenTimeEnabled: map['screenTimeEnabled'] as bool? ?? true,
      screenTimeLimitMinutes: map['screenTimeLimitMinutes'] as int? ?? 120,
      bedtimeHour: map['bedtimeHour'] as int? ?? 21,
      bedtimeMinute: map['bedtimeMinute'] as int? ?? 0,
      contentFilterEnabled: map['contentFilterEnabled'] as bool? ?? true,
      locationSharingEnabled: map['locationSharingEnabled'] as bool? ?? false,
      emergencyBroadcastEnabled: map['emergencyBroadcastEnabled'] as bool? ?? true,
    );
  }

  ParentalSettings copyWith({
    bool? screenTimeEnabled,
    int? screenTimeLimitMinutes,
    int? bedtimeHour,
    int? bedtimeMinute,
    bool? contentFilterEnabled,
    bool? locationSharingEnabled,
    bool? emergencyBroadcastEnabled,
  }) {
    return ParentalSettings(
      screenTimeEnabled: screenTimeEnabled ?? this.screenTimeEnabled,
      screenTimeLimitMinutes: screenTimeLimitMinutes ?? this.screenTimeLimitMinutes,
      bedtimeHour: bedtimeHour ?? this.bedtimeHour,
      bedtimeMinute: bedtimeMinute ?? this.bedtimeMinute,
      contentFilterEnabled: contentFilterEnabled ?? this.contentFilterEnabled,
      locationSharingEnabled: locationSharingEnabled ?? this.locationSharingEnabled,
      emergencyBroadcastEnabled: emergencyBroadcastEnabled ?? this.emergencyBroadcastEnabled,
    );
  }
}