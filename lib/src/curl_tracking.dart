import 'curl_sender.dart';
import 'curl_tracking_navigator_observer.dart';
import 'device_code_manager.dart';

class CurlTracking {
  static CurlTracking? _instance;

  final CurlSender _sender;
  String? _deviceCode;
  String? currentRoute;

  CurlTracking._({required CurlSender sender}) : _sender = sender;

  static CurlTracking? get instance => _instance;

  static final CurlTrackingNavigatorObserver navigatorObserver =
      CurlTrackingNavigatorObserver();

  /// Initialize CurlTracking. Call once at app start.
  static Future<void> init({required String serverUrl}) async {
    final sender = CurlSender(serverUrl: serverUrl);
    _instance = CurlTracking._(sender: sender);
    _instance!._deviceCode = await DeviceCodeManager.getOrCreateCode();
  }

  /// Returns the device code for QC to enter on the web UI.
  static Future<String> getDeviceCode() async {
    return await DeviceCodeManager.getOrCreateCode();
  }

  /// Called by CurlTrackingNavigatorObserver when the active route changes.
  void onRouteChanged(String routeName) {
    currentRoute = routeName;
    if (_deviceCode == null) return;
    _sender.sendRouteChange(deviceCode: _deviceCode!, route: routeName);
  }

  /// Sends a curl log to the server. Called internally by CurlTrackingInterceptor.
  void sendCurlLog({
    required String curl,
    required String method,
    required String url,
  }) {
    if (_deviceCode == null) return;
    _sender.send(
      deviceCode: _deviceCode!,
      curl: curl,
      method: method,
      url: url,
      currentRoute: currentRoute,
    );
  }
}
