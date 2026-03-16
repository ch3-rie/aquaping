// lib/services/socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  static const String SOCKET_URL = 'wss://offscreen-overcool-rosalinda.ngrok-free.dev';

  void connect({Function(Map<String, dynamic>)? onReading}) {
    socket = IO.io(
      SOCKET_URL,
      {
        'transports': ['websocket'],
        'autoConnect': true,
      },
    );

    socket.on('connect', (_) => print("Connected: ${socket.id}"));
    socket.on('disconnect', (_) => print("Disconnected"));

    // 🔥 severity change from backend
    socket.on('severity_change', (data) {
      print("SEVERITY CHANGE EVENT: $data");
      if (onReading != null) onReading(Map<String, dynamic>.from(data));
    });

    // 🔥 dashboard update
    socket.on('dashboard_update', (data) {
      print("DASHBOARD UPDATE: $data");
      if (onReading != null) onReading(Map<String, dynamic>.from(data));
    });
  }

  void disconnect() => socket.disconnect();

  void subscribeDevice(String deviceId) {
    socket.emit("subscribe:device", deviceId);
  }
}
