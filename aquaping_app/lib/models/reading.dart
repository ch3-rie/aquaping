class Reading {
final int id;
final String deviceId;
final int waterLevel;
final String severity;
final DateTime createdAt;
final double? latitude;
final double? longitude;
Reading({
required this.id,
required this.deviceId,
required this.waterLevel,
required this.severity,
required this.createdAt,
this.latitude,
this.longitude,
});
factory Reading.fromJson(Map<String, dynamic> j) => Reading(
id: j['id'],
deviceId: j['device_id'] ?? j['deviceId'] ?? 'device',
waterLevel: j['water_level'] ?? j['waterLevel'] ?? 0,
severity: j['severity'] ?? 'yellow',
createdAt: DateTime.parse(j['created_at'] ?? j['timestamp'] ??
DateTime.now().toIso8601String()),
latitude: j['latitude'] != null ? (j['latitude'] as num).toDouble() : null,
longitude: j['longitude'] != null ? (j['longitude'] as num).toDouble() :
null,
);
}