class PlayerSettings {
  const PlayerSettings({
    this.rememberPosition = true,
    this.autoplayNext = true,
    this.defaultSpeed = 1.0,
    this.skipSeconds = 10,
  });

  final bool rememberPosition;
  final bool autoplayNext;
  final double defaultSpeed;
  final int skipSeconds;

  PlayerSettings copyWith({
    bool? rememberPosition,
    bool? autoplayNext,
    double? defaultSpeed,
    int? skipSeconds,
  }) {
    return PlayerSettings(
      rememberPosition: rememberPosition ?? this.rememberPosition,
      autoplayNext: autoplayNext ?? this.autoplayNext,
      defaultSpeed: defaultSpeed ?? this.defaultSpeed,
      skipSeconds: skipSeconds ?? this.skipSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
        'rememberPosition': rememberPosition,
        'autoplayNext': autoplayNext,
        'defaultSpeed': defaultSpeed,
        'skipSeconds': skipSeconds,
      };

  factory PlayerSettings.fromJson(Map<String, dynamic> json) {
    final speed = (json['defaultSpeed'] as num?)?.toDouble() ?? 1.0;
    final skip = (json['skipSeconds'] as num?)?.toInt() ?? 10;
    return PlayerSettings(
      rememberPosition: json['rememberPosition'] as bool? ?? true,
      autoplayNext: json['autoplayNext'] as bool? ?? true,
      defaultSpeed: speed == 0 ? 1.0 : speed,
      skipSeconds: skip <= 0 ? 10 : skip,
    );
  }
}
