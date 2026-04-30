import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // This file is created by flutterfire configure
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/chat_service.dart';
import 'services/calendar_service.dart';
import 'services/media_service.dart';
import 'services/family_service.dart';
import 'services/location_service.dart';
import 'services/parental_service.dart';
import 'services/bluetooth_service.dart';
import 'services/connection_service.dart';
import 'services/project_service.dart';
import 'services/user_service.dart';
import 'screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const FamilyCircleApp());
}

class FamilyCircleApp extends StatelessWidget {
  const FamilyCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final connectionService = ConnectionService();
    final bluetoothService = BluetoothService();

    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => ChatService()),
        Provider(create: (_) => CalendarService()),
        Provider(create: (_) => MediaService()),
        Provider(create: (_) => FamilyService()),
        Provider(create: (_) => LocationService()),
        Provider(create: (_) => ParentalService()),
        Provider(create: (_) => ProjectService()),
        Provider(create: (_) => UserService()),
        Provider<ConnectionService>.value(value: connectionService),
        Provider<BluetoothService>.value(value: bluetoothService),
      ],
      child: MaterialApp(
        title: 'Family Circle',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const LoginScreen(),
      ),
    );
  }
}