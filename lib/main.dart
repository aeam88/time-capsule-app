import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'injection_container.dart';
import 'core/notifications/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await InjectionContainer().init();
  await NotificationService().init();
  runApp(const TimeCapsuleApp());
}
