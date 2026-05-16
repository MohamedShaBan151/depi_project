import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkStatus { online, offline, unknown }

class NetworkConnectivityService {
  static final NetworkConnectivityService _instance =
      NetworkConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  NetworkStatus _status = NetworkStatus.unknown;

  factory NetworkConnectivityService() {
    return _instance;
  }

  NetworkConnectivityService._internal();

  NetworkStatus get status => _status;

  bool get isOnline => _status == NetworkStatus.online;

  Future<void> init() async {
    _checkConnectivity();
    _connectivity.onConnectivityChanged.listen((results) {
      _handleConnectivityChange(results);
    });
  }

  void _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _handleConnectivityChange(results);
    } catch (e) {
      _status = NetworkStatus.unknown;
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi)) {
      _status = NetworkStatus.online;
    } else if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      _status = NetworkStatus.offline;
    } else {
      _status = NetworkStatus.unknown;
    }
  }

  Future<bool> isConnected() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi);
    } catch (e) {
      return false;
    }
  }
}
