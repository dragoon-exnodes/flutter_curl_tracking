# flutter_curl_tracking

Real-time curl log tracking for Flutter apps. Intercepts Dio requests and streams curl commands to a web UI for debugging and QC.

## Features

- Dio interceptor that captures all HTTP requests as curl commands
- Sends logs to a remote server via WebSocket for real-time web dashboard viewing
- Built-in in-app log viewer with connect code display
- Draggable floating button overlay for quick access
- Auto-generated 6-character device code for pairing with web dashboard

## Setup

### 1. Add dependency

```yaml
# pubspec.yaml
dependencies:
  flutter_curl_tracking:
    path: ../flutter_package # or git URL
```

### 2. Initialize in main.dart

```dart
import 'package:flutter_curl_tracking/flutter_curl_tracking.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize CurlTracking (only in dev/debug)
  if (kDebugMode) {
    await CurlTracking.init(serverUrl: 'http://localhost:8080');
  }

  runApp(const MyApp());
}
```

### 3. Add interceptor to Dio

```dart
import 'package:flutter_curl_tracking/flutter_curl_tracking.dart';

final dio = Dio();

dio.interceptors.addAll([
  // your other interceptors...
  if (kDebugMode) CurlTrackingInterceptor(),
]);
```

### 4. Add floating overlay button

Wrap your app content with `CurlTrackingOverlay` to show a draggable floating button that opens the log viewer.

**Option A: Inside MaterialApp.builder (recommended)**

If your overlay is inside `MaterialApp.builder`, you must pass `navigatorKey` because the context is above the Navigator:

```dart
MaterialApp.router(
  routerConfig: appRouter,
  builder: (context, child) {
    return kDebugMode
        ? CurlTrackingOverlay(
            navigatorKey: yourNavigatorKey, // e.g. GlobalKey<NavigatorState>()
            child: child!,
          )
        : child!;
  },
);
```

**Option B: Below Navigator (simple)**

If wrapped below a Navigator ancestor, no key is needed:

```dart
@override
Widget build(BuildContext context) {
  return CurlTrackingOverlay(
    child: Scaffold(...),
  );
}
```

### 5. Track current route (optional)

Real-time route tracking lets the web dashboard show which screen the app is currently on.

#### Navigator 1.0 / simple apps

Pass `CurlTracking.navigatorObserver` to your `MaterialApp`:

```dart
MaterialApp(
  navigatorObservers: [
    if (kDebugMode) CurlTracking.navigatorObserver,
  ],
  home: const HomeScreen(),
);
```

#### GoRouter (with ShellRoute / nested navigators)

`NavigatorObserver` only catches the root navigator, so it misses routes inside a `ShellRoute`. Use `routeInformationProvider` instead — it fires for **all** navigations regardless of nesting:

```dart
class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(/* your config */);

    if (kDebugMode) {
      _router.routeInformationProvider.addListener(_reportRoute);
      // report initial route after first frame
      WidgetsBinding.instance.addPostFrameCallback((_) => _reportRoute());
    }
  }

  void _reportRoute() {
    final path = _router.routeInformationProvider.value.uri.path;
    if (path.isNotEmpty) CurlTracking.instance?.onRouteChanged(path);
  }

  @override
  void dispose() {
    if (kDebugMode) {
      _router.routeInformationProvider.removeListener(_reportRoute);
    }
    super.dispose();
  }
}
```

#### AutoRoute / other packages

Use `CurlTracking.navigatorObserver` on the **root** navigator. If your router uses nested navigators for tabs/shells, fall back to the `routeInformationProvider` pattern above (or listen to your router's equivalent notifier).

---

### 6. Show connect code in a settings screen (optional)

```dart
import 'package:flutter_curl_tracking/flutter_curl_tracking.dart';

// Get the device code to display
final code = await CurlTracking.getDeviceCode();
// Returns something like "A3F9K2"
```

## Usage

1. Run the Go server: `cd server && go run .`
2. Open the web dashboard: `cd web && npm run dev`
3. Launch your Flutter app
4. Tap the floating button in the app to see the connect code
5. Enter the code on the web dashboard to start monitoring

## API Reference

### CurlTracking

```dart
// Initialize once at app start
await CurlTracking.init(serverUrl: 'http://localhost:8080');

// Get the 6-character device code
final code = await CurlTracking.getDeviceCode();

// Report current route (call whenever the route changes)
CurlTracking.instance?.onRouteChanged('/home');

// Pre-built NavigatorObserver for Navigator 1.0 / basic GoRouter setups
CurlTracking.navigatorObserver; // → CurlTrackingNavigatorObserver
```

### CurlTrackingInterceptor

Dio `Interceptor` that captures requests and:

- Sends curl logs to the remote server (for web dashboard)
- Stores logs locally in `HttpLogsService` (for in-app viewer)

```dart
dio.interceptors.add(CurlTrackingInterceptor());
```

### CurlTrackingOverlay

Draggable floating button widget that opens `CurlLogsView` when tapped.

```dart
CurlTrackingOverlay(
  navigatorKey: navigatorKey, // optional, needed if above Navigator
  child: yourWidget,
)
```

### CurlLogsView

Standalone screen showing the connect code and all intercepted requests. Can be pushed directly:

```dart
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => const CurlLogsView()),
);
```

### HttpLogsService

Singleton in-memory log storage. Access directly if needed:

```dart
final logs = HttpLogsService.instance.logs;
HttpLogsService.instance.clear();
```
