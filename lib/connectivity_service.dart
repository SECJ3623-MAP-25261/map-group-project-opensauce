import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityService {
  Stream<bool> get connectivityStream =>
      Connectivity().onConnectivityChanged.map((results) {
        return !results.contains(ConnectivityResult.none);
      });

  Future<bool> isConnected() async {
    final results = await Connectivity().checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }
}

final connectivityProvider = StreamProvider<bool>((ref) {
  return ConnectivityService().connectivityStream;
});