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
    print('[SOCKET] Connect called. Current state: ${_socket?.connected ?? false}');

    if (_socket != null && _socket!.connected) {
      print('[SOCKET] Already connected, skipping');
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
      print('✅ [SOCKET] Connected to server');
      _authenticate();
    });

    _socket!.onDisconnect((reason) {
      print('❌ [SOCKET] Disconnected. Reason: $reason');
    });

    _socket!.onConnectError((error) {
      print('❌ [SOCKET] Connection error: $error');
    });

    _socket!.onError((error) {
      print('❌ [SOCKET] Error: $error');
    });

    // Listen to events
    _setupEventListeners();
  }

  void _authenticate() {
    final token = _storage.getToken();
    print('[SOCKET] Authenticating with token: ${token?.substring(0, 8)}...');

    if (token != null) {
      _socket!.emit(ApiConfig.socketAuthenticate, {'token': token});
    } else {
      print('⚠️ [SOCKET] No token found for authentication');
    }
  }

  void _setupEventListeners() {
    _socket!.on(ApiConfig.socketAuthenticated, (data) {
      print('✅ [SOCKET-EVENT] authenticated: $data');
      if (onAuthenticated != null) {
        onAuthenticated!(data as Map<String, dynamic>);
      }
    });

    _socket!.on(ApiConfig.socketNokDesignated, (data) {
      print('👤 [SOCKET-EVENT] nok:designated received: $data');
      if (onNokDesignated != null) {
        onNokDesignated!(data as Map<String, dynamic>);
      }
    });

    _socket!.on(ApiConfig.socketNokAccepted, (data) {
      print('✅ [SOCKET-EVENT] nok:accepted received!');
      print('✅ [SOCKET-EVENT] Data: $data');
      print('✅ [SOCKET-EVENT] Callback exists: ${onNokAccepted != null}');

      if (onNokAccepted != null) {
        print('✅ [SOCKET-EVENT] Calling onNokAccepted callback');
        onNokAccepted!(data as Map<String, dynamic>);
      } else {
        print('⚠️ [SOCKET-EVENT] onNokAccepted callback is NULL!');
      }
    });

    _socket!.on(ApiConfig.socketNokRejected, (data) {
      print('❌ [SOCKET-EVENT] nok:rejected received: $data');
      print('❌ [SOCKET-EVENT] Callback exists: ${onNokRejected != null}');

      if (onNokRejected != null) {
        onNokRejected!(data as Map<String, dynamic>);
      }
    });

    _socket!.on(ApiConfig.socketDeathVerified, (data) {
      print('✅ [SOCKET-EVENT] death:verified received: $data');
      if (onDeathVerified != null) {
        onDeathVerified!(data as Map<String, dynamic>);
      }
    });

    _socket!.on(ApiConfig.socketError, (data) {
      print('❌ [SOCKET-EVENT] error: $data');
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
    _socket!.emit(ApiConfig.socketNokAccept, {
      'designationId': designationId,
    });
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

