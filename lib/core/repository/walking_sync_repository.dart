import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:health/health.dart';
import 'package:health_kit_reporter/health_kit_reporter.dart';
import 'package:health_kit_reporter/model/predicate.dart';
import 'package:health_kit_reporter/model/type/quantity_type.dart';
import 'package:health_kit_reporter/model/update_frequency.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wicando/core/services/storage_service.dart';
import 'package:wicando/core/utils.dart';
import 'package:wicando/core/walking/walking_bloc.dart';
import 'package:wicando/main.dart';

class BackgroundFetchRepository {
  static Future<void> startIosSyncStepsTask() async {
    final identifier = QuantityType.stepCount.identifier;
    final predicate = Predicate(
      DateTime.now().toMidnightDate(),
      DateTime.now(),
    );

    HealthKitReporter.observerQuery(
      [identifier],
      predicate,
      onUpdate: (identifier) async {
        final preferredUnits = await HealthKitReporter.preferredUnits([QuantityType.stepCount]);

        for (var preferredUnit in preferredUnits) {
          final identifier = preferredUnit.identifier;
          final unit = preferredUnit.unit;
          final type = QuantityTypeFactory.from(identifier);

          try {
            final statistics = await HealthKitReporter.statisticsQuery(type, unit, predicate);
            final steps = statistics.harmonized.summary?.toInt();

            if (steps != null) {
              await _syncSteps(steps);
            }
          } catch (ex, stack) {
            logger.d('ios sync task error', ex, stack);
          }
        }
      },
    );

    await HealthKitReporter.enableBackgroundDelivery(
      identifier,
      UpdateFrequency.immediate,
    );
  }

  static Future<void> stopIosSyncStepsTask() => HealthKitReporter.disableAllBackgroundDelivery();

  static Future<int> startAndroidBackgroundTask() {
    return BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        startOnBoot: true,
        enableHeadless: true,
        requiredNetworkType: NetworkType.ANY,
      ),
      (String taskId) async {
        final steps = await _getStepsAndroid();
        await _syncSteps(steps);
        BackgroundFetch.finish(taskId);
      },
      (String taskId) async {
        BackgroundFetch.finish(taskId);
      },
    );
  }

  static Future<int> _getStepsAndroid() async {
    try {
      final types = [HealthDataType.STEPS];

      // requesting access to the data types before reading them
      final allowUse = await HealthFactory.hasPermissions(types);

      if (allowUse != null && allowUse) {
        final now = DateTime.now();
        // get the number of steps for today
        final midnight = DateTime(now.year, now.month, now.day);
        final steps = await HealthFactory().getTotalStepsInInterval(midnight, now);

        return steps ?? 0;
      }

      return 0;
    } catch (ex) {
      return 0;
    }
  }

  static Future<void> _syncSteps(int steps) async {
    try {
      final storageService = StorageService(await SharedPreferences.getInstance());

      final lastSyncDateString = storageService.lastSyncDate;
      final newSyncDate = DateTime.now().toMidnightDate();

      if (lastSyncDateString == null) {
        await storageService.resetWalkingStore(steps, newSyncDate);
      } else {
        final lastSyncDate = DateTime.parse(lastSyncDateString).toLocal().toMidnightDate();

        final diffDays = newSyncDate.difference(lastSyncDate).inDays;
        if (diffDays > 0) {
          await storageService.resetWalkingStore(steps, newSyncDate);
        } else {
          final isCompleted = storageService.walkingCompleteEvent ?? false;
          if (isCompleted) {
            return;
          }

          final todaySteps = steps;

          if (todaySteps >= MAX_TODAY_STEPS) {
            await storageService.setWalkingEventComplete();
          }
        }
      }
    } catch (ex, stack) {
      logger.d(ex, stack);
    }
  }
}
