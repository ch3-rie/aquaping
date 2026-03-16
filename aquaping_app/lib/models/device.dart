// lib/models/device.dart
class DeviceModel {
  final String deviceId;
  final String? name;
  DeviceModel({required this.deviceId, this.name});
  factory DeviceModel.fromJson(Map<String,dynamic> j) => DeviceModel(deviceId: j['device_id'], name: j['name']);
}
