import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_check/gms_check.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wicando/core/repository/walking_sync_repository.dart';
import 'package:wicando/core/services/storage_service.dart';
import 'package:wicando/core/walking/walking_bloc.dart';
import 'package:wicando/ui/pages/main/widget/walking_activity.dart';

final logger = Logger();
late bool isGmsAvailable;

Future<void> main() async {
  isGmsAvailable = await GmsCheck().checkGmsAvailability(enableLog: kDebugMode) ?? true;

  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  if (Platform.isAndroid) {
    await BackgroundFetchRepository.startAndroidBackgroundTask();
  }

  runZonedGuarded(
    () => runApp(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (_) => prefs, lazy: false),
          RepositoryProvider(create: (_) => storageService, lazy: false),
        ],
        child: const MyApp(),
      ),
    ),
    (object, stackTrace) => logger.d('error', object, stackTrace),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiSteps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => WalkingBloc(
                context.read(),
              ),
            ),
          ],
          child: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: WalkingActivity()),
    );
  }
}
