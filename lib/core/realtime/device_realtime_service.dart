import 'dart:async';
import 'dart:developer';
import 'package:logging/logging.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:thermo_humi/core/config/app_config.dart';
import 'package:thermo_humi/core/realtime/models/realtime_connection_state.dart';
import 'package:thermo_humi/core/storage/secure_storage.dart';
import 'package:thermo_humi/features/room/data/models/device_online_model.dart';

import 'package:thermo_humi/core/constants/app_constants.dart';

class DeviceRealtimeService {
  final SecureStorage _secureStorage;
  HubConnection? _hubConnection;

  // StreamControllers for exposing events
  final _connectionStateController =
      StreamController<RealtimeConnectionState>.broadcast();
  final _deviceUpdatesController =
      StreamController<DeviceOnlineModel>.broadcast();

  // Expose Streams
  Stream<RealtimeConnectionState> get connectionStateStream =>
      _connectionStateController.stream;
  Stream<DeviceOnlineModel> get deviceUpdatesStream =>
      _deviceUpdatesController.stream;

  RealtimeConnectionState _currentState = RealtimeConnectionState.disconnected;
  RealtimeConnectionState get currentState => _currentState;

  DeviceRealtimeService(this._secureStorage) {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print(
        '[SignalR Internal] ${rec.level.name}: ${rec.time}: ${rec.message}',
      );
    });

    _updateState(RealtimeConnectionState.disconnected);
  }

  void _updateState(RealtimeConnectionState state) {
    _currentState = state;
    _connectionStateController.add(state);
    print('SignalR State: ${state.name}');
  }

  Future<void> connect() async {
    if (_currentState == RealtimeConnectionState.connected ||
        _currentState == RealtimeConnectionState.connecting) {
      print('SignalR is already connected or connecting.');
      return;
    }

    _updateState(RealtimeConnectionState.connecting);

    try {
      final url = '${AppConfig.devicesBaseUrl}/hubs/frontend-online';
      print('SignalR Connecting to URL: $url');

      _hubConnection = HubConnectionBuilder()
          .withUrl(
            url,
            options: HttpConnectionOptions(
              transport: HttpTransportType.WebSockets,
              logMessageContent: true,
              logger: Logger('SignalR'),
              accessTokenFactory: () async {
                final token = await _secureStorage.read(
                  AppConstants.kAccessToken,
                );
                return token ?? '';
              },
            ),
          )
          .withAutomaticReconnect(retryDelays: [0, 2000, 10000, 30000])
          .build();

      _hubConnection?.onclose(({error}) {
        print('SignalR Closed: $error');
        _updateState(RealtimeConnectionState.disconnected);
      });

      _hubConnection?.onreconnecting(({error}) {
        print('SignalR Reconnecting: $error');
        _updateState(RealtimeConnectionState.reconnecting);
      });

      _hubConnection?.onreconnected(({connectionId}) {
        print('SignalR Reconnected. ID: $connectionId');
        _updateState(RealtimeConnectionState.connected);
      });

      // Lắng nghe sự kiện DeviceUpdated
      _hubConnection?.on('DeviceUpdated', _onDeviceUpdated);

      await _hubConnection?.start();
      _updateState(RealtimeConnectionState.connected);
    } catch (e) {
      print('SignalR Connection Error: $e');
      _updateState(RealtimeConnectionState.disconnected);
    }
  }

  void _onDeviceUpdated(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) {
      print('SignalR: Received DeviceUpdated but arguments are empty.');
      return;
    }

    try {
      final data = arguments.first;
      print('SignalR: Received DeviceUpdated -> $data');
      if (data is Map<String, dynamic>) {
        final event = DeviceOnlineModel.fromJson(data);
        _deviceUpdatesController.add(event);
      } else {
        print('SignalR: DeviceUpdated data is not a Map: ${data.runtimeType}');
      }
    } catch (e) {
      print('Error parsing DeviceUpdated event: $e');
    }
  }

  Future<void> stop() async {
    if (_hubConnection != null) {
      _hubConnection?.off('DeviceUpdated');
      await _hubConnection?.stop();
      _hubConnection = null;
    }
    _updateState(RealtimeConnectionState.disconnected);
  }

  void dispose() {
    stop();
    _connectionStateController.close();
    _deviceUpdatesController.close();
  }
}
