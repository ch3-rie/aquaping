// lib/models/user.dart
class UserModel {
  final int id;
  final String email;
  final String? name;
  UserModel({required this.id, required this.email, this.name});
  factory UserModel.fromJson(Map<String,dynamic> j) => UserModel(id: j['id'], email: j['email'], name: j['name']);
}
