import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:health/health.dart';
import 'package:health_kit_reporter/health_kit_reporter.dart';
import 'package:health_kit_reporter/model/predicate.dart';
import 'package:health_kit_reporter/model/type/quantity_type.dart';
import 'package:wicando/core/repository/walking_sync_repository.dart';
import 'package:wicando/core/services/storage_service.dart';
import 'package:wicando/core/utils.dart';
import 'package:wicando/main.dart';

part 'walking_event.dart';
part 'walking_state.dart';

const MAX_TODAY_STEPS = 10000;

class WalkingBloc extends Bloc<WalkingEvent, WalkingState> {
  final StorageService _storageService;

  WalkingBloc(
    this._storageService,
  ) : super(const WalkingState()) {
    on<WalkingStarted>(_onWalkingStarted);
    on<WalkingInitEvent>(_onWalkingInit);
    on<WalkingCompleteEvent>(_onWalkingComplete);
    on<WalkingResetEvent>(_onWalkingReset);
    on<WalkingStepsChanged>(_onWalkingStepsChanged);
    on<WalkingDebugEvent>(_onWalkingDebug);
  }

  StreamSubscription? _iosStepsStream;
  Timer? _syncTimer;

  var _isIosMode = false;

  final _health = HealthFactory();

  Future<void> _onWalkingStarted(WalkingStarted event, Emitter<WalkingState> emit) async {
    final isIosMode = event.isIosMode;
    if (isIosMode != null) {
      _isIosMode = isIosMode;
    }

    if (_isIosMode) {
      add(const WalkingDebugEvent('[init]: Используется Health Kit'));
      await _startIosStepsStream();
    } else {
      add(const WalkingDebugEvent('[init]: Используется Google Fit'));
      await _startAndroidStepsStream();
    }
  }

  Future<void> _startIosStepsStream() async {
    try {
      add(const WalkingInitEvent(0));
    } catch (ex, stack) {
      add(WalkingDebugEvent('[startIosStream]: ошибка стрима: $ex'));
      logger.d(ex, stack);
    }

    await BackgroundFetchRepository.startIosSyncStepsTask();

    _syncTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final preferredUnits = await HealthKitReporter.preferredUnits([QuantityType.stepCount]);

      for (var preferredUnit in preferredUnits) {
        final nowDate = DateTime.now();

        try {
          final statistics = await HealthKitReporter.statisticsQuery(
            QuantityTypeFactory.from(preferredUnit.identifier),
            preferredUnit.unit,
            Predicate(nowDate.toMidnightDate(), nowDate),
          );

          add(WalkingDebugEvent('[iosTimer]: статистика из HKP: ${statistics.map.toString()}'));

          final steps = statistics.harmonized.summary?.toInt() ?? 0;

          add(WalkingDebugEvent('[iosTimer]: считывание шагов по таймеру: $steps'));
          await _stepsChangedListener(steps);
        } catch (ex, stack) {
          add(WalkingDebugEvent('[iosTimer]: не удалось считать шаги по таймеру: $stack'));
          logger.d(ex, stack);
        }
      }
    });
  }

  Future<void> _startAndroidStepsStream() async {
    // define the types to get
    final types = [HealthDataType.STEPS];

    try {
      // requesting access to the data types before reading them
      final allowUse = await _health.requestAuthorization(types);

      if (allowUse) {
        add(const WalkingInitEvent(0));

        _syncTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
          try {
            final now = DateTime.now();
            // get the number of steps for today
            final midnight = DateTime(now.year, now.month, now.day);
            final steps = await _health.getTotalStepsInInterval(midnight, now);
            add(WalkingDebugEvent('[startAndroidStream]: Значение из Google Fit: $steps'));

            await _stepsChangedListener(steps ?? 0);
          } catch (ex) {
            add(WalkingDebugEvent('[startAndroidStream]: ошибка стрима: $ex'));
          }
        });
      }
    } catch (ex, stack) {
      add(WalkingDebugEvent('[iosTimer]: не удалось считать шаги по таймеру: $stack'));
      logger.d(ex, stack);
    }
  }

  Future<void> _onWalkingInit(WalkingInitEvent event, Emitter<WalkingState> emit) async {
    add(const WalkingDebugEvent('[initEvent]: Инициализация шагомера'));

    final lastSyncDateString = _storageService.lastSyncDate;
    final newSyncDate = DateTime.now().toMidnightDate();

    if (lastSyncDateString == null) {
      add(const WalkingDebugEvent('[initEvent]: Шагомер инициализируется впервые'));
      if (Platform.isAndroid) {
        add(WalkingResetEvent(0, newSyncDate));
      } else {
        add(WalkingResetEvent(event.steps, newSyncDate));
      }
    } else {
      final lastSyncDate = DateTime.parse(lastSyncDateString).toLocal().toMidnightDate();
      final diffDays = newSyncDate.difference(lastSyncDate).inDays;
      final isCompleted = _storageService.walkingCompleteEvent ?? false;

      final steps = event.steps;
      if (diffDays > 0) {
        add(
          const WalkingDebugEvent(
            '[initEvent]: Инициализация шагомера. Наступил следующий день',
          ),
        );
        add(WalkingResetEvent(steps, newSyncDate));
      } else {
        emit(
          state.copyWith(
            status: isCompleted ? ActivityStatus.COMPLETED : ActivityStatus.AVAILABLE,
            lastSyncDate: lastSyncDate,
          ),
        );
      }
    }
  }

  Future<void> _onWalkingReset(WalkingResetEvent event, Emitter<WalkingState> emit) async {
    add(
      WalkingDebugEvent(
        '[resetEvent]: Сброс значения шагомера. '
        'Последняя дата синхронизации: ${event.syncDate}',
      ),
    );

    await _storageService.resetWalkingStore(event.steps, event.syncDate);

    emit(
      state.copyWith(
        status: event.status ?? ActivityStatus.AVAILABLE,
        stepCount: event.steps,
        lastSyncDate: event.syncDate,
      ),
    );
  }

  Future<void> _stepsChangedListener(final int steps) async {
    if (state.status == ActivityStatus.UNKNOWN || state.lastSyncDate == null) {
      add(
        WalkingDebugEvent(
          '[stepsChangedListener]: Неопределенное состояние шагомера. Шаги $steps',
        ),
      );
      return;
    }

    final newSyncDate = DateTime.now().toMidnightDate();
    final diffDays = newSyncDate.difference(state.lastSyncDate!).inDays;

    if (diffDays > 0) {
      add(
        const WalkingDebugEvent(
          '[stepsChangedListener]: Наступил следующий день. Сброс счетчика шагомера.',
        ),
      );
      add(WalkingResetEvent(steps, newSyncDate));
    } else {
      final todaySteps = steps;

      if (todaySteps >= MAX_TODAY_STEPS && state.status != ActivityStatus.COMPLETED) {
        add(
          WalkingDebugEvent(
            '[stepsChangedListener]: Выполнены условия завершения активности '
            'шагомера. Шаги $todaySteps',
          ),
        );
        // завершаем активность
        if (state.status != ActivityStatus.COMPLETING) {
          add(WalkingCompleteEvent(steps));
        }
      }

      add(WalkingStepsChanged(todaySteps));
    }
  }

  Future<void> _onWalkingStepsChanged(WalkingStepsChanged event, Emitter<WalkingState> emit) async {
    add(
      WalkingDebugEvent(
        '[stepsChangedEvent]: Новое значения шагомера в ${DateTime.now()}: ${event.steps}',
      ),
    );

    emit(state.copyWith(stepCount: event.steps));
  }

  Future<void> _onWalkingComplete(WalkingCompleteEvent event, Emitter<WalkingState> emit) async {
    if (state.status == ActivityStatus.COMPLETING) {
      add(const WalkingDebugEvent('[completeEvent]: Ожидание завершения активности...'));
      emit(state.copyWith());
    } else {
      try {
        add(const WalkingDebugEvent('[completeEvent]: Завершение активности шагомера...'));
        emit(state.copyWith(status: ActivityStatus.COMPLETING));

        await _storageService.setWalkingEventComplete();

        add(const WalkingDebugEvent('[completeEvent]: Активность шагомера успешно завершена.'));
        emit(state.copyWith(status: ActivityStatus.COMPLETED));
      } catch (ex, stack) {
        add(WalkingDebugEvent('[completeEvent]: Ошибка завершения активности шагомера: $stack'));
        emit(state.copyWith(status: ActivityStatus.FAILED));
      }
    }
  }

  Future<void> _onWalkingDebug(WalkingDebugEvent event, Emitter<WalkingState> emit) async {
    final newEvents = state.events ?? []
      ..add(event.event);

    emit(state.copyWith(events: newEvents));
  }

  @override
  Future<void> close() async {
    if (_iosStepsStream != null) {
      await _iosStepsStream?.cancel();
    }

    if (_syncTimer != null) {
      _syncTimer?.cancel();
    }

    return super.close();
  }
}
