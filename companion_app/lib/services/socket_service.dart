import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/api_config.dart';
import 'storage_service.dart';

class SocketService {
  IO.Socket? _socket;
  final StorageService _storage = StorageService();
  
  // Callbacks
  Function(Map<String, dynamic>)? onAuthenticated;
  Function(Map<String, dynamic>)? onNokDesignated;
  Function(Map<String, dynamic>)? onNokAccepted;
  Function(Map<String, dynamic>)? onNokRejected;
  Function(Map<String, dynamic>)? onDeathVerified;
  Function(String)? onError;

  // Singleton
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  bool get isConnected => _socket?.connected ?? false;

  void connect() {
    if (_socket != null && _socket!.connected) {
      print('🔌 Socket already connected');
      return;
    }

    _socket = IO.io(
      ApiConfig.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('🔌 Socket connected');
      _authenticate();
    });

    _socket!.onDisconnect((_) {
      print('🔌 Socket disconnected');
    });

    _socket!.onConnectError((error) {
      print('❌ Socket connection error: $error');
    });

    _socket!.onError((error) {
      print('❌ Socket error: $error');
    });

    // Listen to events
    _setupEventListeners();
  }

  void _authenticate() {
    final token = _storage.getToken();
    if (token != null) {
      print('🔐 Authenticating socket with token');
      _socket!.emit(ApiConfig.socketAuthenticate, {'token': token});
    }
  }

  void _setupEventListeners() {
    _socket!.on(ApiConfig.socketAuthenticated, (data) {
      print('✅ Socket authenticated: $data');
      if (onAuthenticated != null) {
        onAuthenticated!(data as Map<String, dynamic>);
      }
    });

    _socket!.on(ApiConfig.socketNokDesignated, (data) {
      print('👤 NOK designation received: $data');
      if (onNokDesignated != null) {
        onNokDesignated!(data as Map<String, dynamic>);
      }
    });

    _socket!.on(ApiConfig.socketNokAccepted, (data) {
      print('✅ NOK accepted: $data');
      if (onNokAccepted != null) {
        onNokAccepted!(data as Map<String, dynamic>);
      }
    });

    _socket!.on(ApiConfig.socketNokRejected, (data) {
      print('❌ NOK rejected: $data');
      if (onNokRejected != null) {
        onNokRejected!(data as Map<String, dynamic>);
      }
    });

    _socket!.on(ApiConfig.socketDeathVerified, (data) {
      print('✅ Death verified: $data');
      if (onDeathVerified != null) {
        onDeathVerified!(data as Map<String, dynamic>);
      }
    });

    _socket!.on(ApiConfig.socketError, (data) {
      print('❌ Socket error event: $data');
      if (onError != null) {
        final message = data is Map ? data['message'] as String? ?? 'Unknown error' : data.toString();
        onError!(message);
      }
    });
  }

  void emitNokDesignate(String designationId) {
    _socket!.emit(ApiConfig.socketNokDesignate, {
      'designationId': designationId,
    });
  }

  void emitNokAccept(String designationId) {
    print('📤 [SOCKET-EMIT] Attempting to emit nok:accept for $designationId');
    print('📤 [SOCKET-EMIT] Socket exists: ${_socket != null}');
    print('📤 [SOCKET-EMIT] Socket connected: ${_socket?.connected ?? false}');

    if (_socket == null || !_socket!.connected) {
      print('❌ [SOCKET-EMIT] Cannot emit - socket not connected!');
      return;
    }

    _socket!.emit(ApiConfig.socketNokAccept, {
      'designationId': designationId,
    });

    print('✅ [SOCKET-EMIT] Emission completed for nok:accept');
  }

  void emitNokReject(String designationId) {
    _socket!.emit('nok:reject', {
      'designationId': designationId,
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}

