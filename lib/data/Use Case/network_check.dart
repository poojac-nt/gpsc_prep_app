import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

// Define an interface for better testability and flexibility

class NetworkCheckUseCase {
  final Connectivity _connectivity;
  final http.Client _httpClient;
  final String internetCheckUrl;
  final Duration internetCheckTimeout;

  NetworkCheckUseCase({
    required Connectivity connectivity,
    required http.Client httpClient,
    this.internetCheckUrl = ' https://example.com', // Default but configurable
    this.internetCheckTimeout = const Duration(
      seconds: 10,
    ), // Default but configurable
  }) : _connectivity = connectivity,
       _httpClient = httpClient;

  /// Checks if the device is connected to Wi-Fi or Mobile network.

  Future<bool> isConnectedToNetwork() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    const List<ConnectivityResult> validConnections = [
      ConnectivityResult.mobile,
      ConnectivityResult.wifi,
      ConnectivityResult.ethernet,
      ConnectivityResult.vpn, // Optional
      ConnectivityResult.other, // If you want to be safe
    ];

    return validConnections.contains(connectivityResult);
  }

  /// Checks if the internet is actually reachable by making an HTTP request.
  Future<bool> hasInternetAccess() async {
    try {
      print(
        'Attempting to reach: $internetCheckUrl with timeout: $internetCheckTimeout',
      );
      final response = await _httpClient
          .get(Uri.parse(internetCheckUrl))
          .timeout(internetCheckTimeout);
      print('HTTP response status code: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error checking internet access: $e');
      // If the error is a TimeoutException, you'll see it here.
      // If it's a SocketException (e.g., host lookup failed), you'll see it here.
      return false;
    }
  }

  /// Returns true only if device is both connected to a network and has internet access.
  Future<bool> isOnline() async {
    final isConnected = await isConnectedToNetwork();
    print('Is connected to network: $isConnected');

    if (!isConnected) return false;

    final hasInternet = await hasInternetAccess();
    print('Has internet access: $hasInternet');

    return hasInternet;
  }
}
