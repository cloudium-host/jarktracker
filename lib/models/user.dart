class Subscription {
  Subscription({
    required this.permanent,
    this.expirationTimestamp,
    this.daysRemaining,
  });

  final bool permanent;
  final int? expirationTimestamp;
  final int? daysRemaining;

  factory Subscription.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Subscription(permanent: true);
    }
    return Subscription(
      permanent: json['permanent'] as bool? ?? false,
      expirationTimestamp: (json['expiration_timestamp'] as num?)?.toInt(),
      daysRemaining: (json['days_remaining'] as num?)?.toInt(),
    );
  }
}

class AppUser {
  AppUser({
    required this.email,
    required this.phoneNumber,
    required this.avatarUrl,
    required this.subscription,
    required this.unitOfDistance,
    required this.dateFormat,
    required this.timeFormat,
    this.timezoneId,
  });

  final String email;
  final String phoneNumber;
  final String? avatarUrl;
  final Subscription subscription;
  final String unitOfDistance;
  final String dateFormat;
  final String timeFormat;
  final int? timezoneId;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        email: json['email'] as String? ?? '',
        phoneNumber: json['phone_number'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String?,
        subscription: Subscription.fromJson(json['subscription'] as Map<String, dynamic>?),
        unitOfDistance: json['unit_of_distance'] as String? ?? 'km',
        dateFormat: json['date_format'] as String? ?? 'Y-m-d',
        timeFormat: json['time_format'] as String? ?? 'H:i:s',
        timezoneId: (json['timezone_id'] as num?)?.toInt(),
      );
}
