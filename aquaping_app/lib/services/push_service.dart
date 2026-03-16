import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class PushService {
  static Future<void> init(String userId) async {
    final fcm = FirebaseMessaging.instance;

    await fcm.requestPermission();

    final token = await fcm.getToken();
    if (token != null) {
      await http.post(
        Uri.parse("http://YOUR_SERVER/fcm/save-token"),
        body: {"user_id": userId, "token": token},
      );
    }

    FirebaseMessaging.onMessage.listen((msg) {
      print("Foreground message: ${msg.notification?.title}");
    });
  }
}
