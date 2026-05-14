class Sharing {
  Sharing({
    required this.id,
    required this.name,
    required this.hash,
    required this.url,
    required this.active,
    this.expirationDate,
  });

  final int id;
  final String name;
  final String hash;
  final String url;
  final bool active;
  final DateTime? expirationDate;

  factory Sharing.fromJson(Map<String, dynamic> json) {
    final exp = json['expiration_date'] as String?;
    return Sharing(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      hash: (json['hash'] as String?) ?? '',
      url: (json['url'] as String?) ?? '',
      active: (json['active'] as bool?) ?? true,
      expirationDate: exp == null ? null : DateTime.tryParse(exp),
    );
  }
}
