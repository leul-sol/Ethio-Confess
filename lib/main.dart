import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:ethioconfess/widgets/auth_wrapper.dart';
import 'providers/service_providers.dart';
import 'widgets/error_handler_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ethioconfess/services/sync_service.dart';
import 'package:ethioconfess/services/queue_service.dart';
import 'package:ethioconfess/screens/chat/chat_detail_screen.dart';
import 'package:ethioconfess/models/conversation.dart';
import 'package:ethioconfess/services/cloudinary_service.dart';
import 'dart:developer' as developer;
// Vent detail screen for deep linking from notifications
import 'package:ethioconfess/screens/vent/vent_detail_screen.dart';

// Global navigator key to allow navigation from OneSignal handlers
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Avoid crash when offline: don't fetch fonts from network; use fallback if needed
  GoogleFonts.config.allowRuntimeFetching = false;

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Debug print environment variables
  developer.log('=== ENVIRONMENT VARIABLES DEBUG ===');
  developer.log('WebSocket URL: ${dotenv.env['WS_URL'] ?? 'Not set'}');
  developer.log(
      'Cloudinary Cloud Name: ${dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? 'Not set'}');
  developer.log(
      'Cloudinary API Key: ${dotenv.env['CLOUDINARY_API_KEY'] != null ? 'Set' : 'Not set'}');
  developer.log(
      'Cloudinary API Secret: ${dotenv.env['CLOUDINARY_API_SECRET'] != null ? 'Set' : 'Not set'}');
  developer.log(
      'Cloudinary Upload Preset: ${dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'Not set'}');
  developer
      .log('OneSignal App ID: ${dotenv.env['ONE_SIGNAL_APP_ID'] ?? 'Not set'}');
  developer.log('=== ENVIRONMENT VARIABLES DEBUG END ===');

  // Initialize Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  await Hive.openBox('biographyCache');
  await Hive.openBox('ventCache');

  // Initialize QueueService
  final queueService = QueueService();
  await queueService.init();

  // Initialize GraphQL client and services
  final container = ProviderContainer();
  final graphQLClientFuture = container.read(graphQLClientProvider);

  // Test Cloudinary configuration
  await CloudinaryService.testConfiguration();

  // Initialize SyncService with the client future
  final syncService = SyncService(container, queueService, graphQLClientFuture);
  await syncService.startSync();

  // Open the cache box with proper typing
  await Hive.openBox<Map<dynamic, dynamic>>('graphql_cache');

  timeago.setLocaleMessages('en_short', timeago.EnShortMessages());
  // Initialize OneSignal
  // Enable verbose logging for debugging (remove in production)
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  // Initialize with your OneSignal App ID
  OneSignal.initialize(dotenv.env['ONE_SIGNAL_APP_ID'] ?? '');
  // Use this method to prompt for push notifications.
  // We recommend removing this method after testing and instead use In-App Messages to prompt for notification permission.
  OneSignal.Notifications.requestPermission(true);

  // Handle notification clicks to deep link to specific screens
  OneSignal.Notifications.addClickListener((OSNotificationClickEvent event) {
    try {
      final notification = event.notification;
      final Map<String, dynamic> data =
          (notification.additionalData ?? const <String, dynamic>{})
              .cast<String, dynamic>();

      // Expected payload from server
      // e.g. { type: 'vent_created'|'vent_reply', vent_id: '<id>' }
      final String? type =
          (data['type'] ?? data['notification_type'] ?? data['kind'])
              ?.toString();
      final String? ventId =
          (data['vent_id'] ?? data['ventId'] ?? data['id'])?.toString();

      if (ventId != null && ventId.isNotEmpty) {
        // Navigate to VentDetailScreen
        rootNavigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => VentDetailScreen(ventId: ventId),
          ),
        );
        return;
      }

      // If no ventId, you could route to home or a fallback if desired
      developer.log(
          '[OneSignal] No ventId found in notification data. type=$type data=$data');
    } catch (e, st) {
      developer.log('[OneSignal] Error handling notification open: $e');
      developer.log(st.toString());
    }
  });

  runApp(AppRoot());
}

class AppRoot extends StatefulWidget {
  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  int _providerKey = 0;

  void restartApp() {
    setState(() {
      _providerKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      key: ValueKey(_providerKey),
      child: MyApp(onLogout: restartApp),
    );
  }
}

class MyApp extends StatelessWidget {
  final VoidCallback? onLogout;
  const MyApp({Key? key, this.onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ethio Confess',
      debugShowCheckedModeBanner: false,
      navigatorKey: rootNavigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(65, 105, 225, 1),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.light().textTheme,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: ErrorHandlerWidget(
        child: AuthWrapper(onLogout: onLogout),
      ),
      routes: {
        '/chat': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          final conversation = Conversation(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            participantId: args['participantId'],
            participantName: args['participantName'],
            lastMessage: '',
            lastMessageTime: DateTime.now(),
            unreadCount: 0,
          );
          return ChatDetailScreen(
            conversation: conversation,
          );
        },
      },
    );
  }
}
