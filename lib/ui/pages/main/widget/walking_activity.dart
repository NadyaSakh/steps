import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health/health.dart';
import 'package:health_kit_reporter/health_kit_reporter.dart';
import 'package:health_kit_reporter/model/type/quantity_type.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wicando/core/walking/walking_bloc.dart';
import 'package:wicando/main.dart';
import 'package:wicando/ui/common/app_theme.dart';
import 'package:wicando/ui/common/snackbars.dart';
import 'package:wicando/ui/common/widgets/bonus_badge.dart';
import 'package:wicando/ui/common/widgets/text_widget.dart';

const GOOGLE_FIT_APP_LINK =
    'https://play.google.com/store/apps/details?id=com.google.android.apps.fitness&hl=ru';

class WalkingActivity extends StatefulWidget {
  const WalkingActivity({Key? key}) : super(key: key);

  @override
  State createState() => _WalkingActivityState();
}

class _WalkingActivityState extends State<WalkingActivity> with WidgetsBindingObserver {
  PermissionStatus? _walkingActivityStatus;
  bool? _allowUseGoogleFit;
  late WalkingBloc walkingBloc;

  @override
  void initState() {
    super.initState();
    walkingBloc = context.read<WalkingBloc>();

    if (mounted) {
      WidgetsBinding.instance.addObserver(this);
      _checkStepsAuthorization();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _checkStepsAuthorization();
    }
  }

  @override
  Widget build(BuildContext context) {
    final healthIcon = Image.asset(
      Platform.isAndroid ? 'assets/ic_google_fit.png' : 'assets/ic_apple_health.png',
      height: 30,
      fit: BoxFit.fitHeight,
    );

    return GestureDetector(
      onTap: () => _onActivityTap(context),
      child: BlocConsumer<WalkingBloc, WalkingState>(
        listenWhen: (prev, current) => prev.status != current.status,
        listener: (context, state) => _onActivityStateChanged(state),
        builder: (context, state) => Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: _backgroundByStatus(context, state),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Subtitle(
                    'Walk 10,000 steps in a day',
                    color: AppColors.slateGray,
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.bold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  BonusBadge(
                    10,
                    backgroundColor: _showProgress(state.status) ? AppColors.denim : Colors.black38,
                  ),
                ],
              ),
              SizedBox(height: _showProgress(state.status) ? 13 : 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: _showProgress(state.status) ? 0 : 2),
                    child: healthIcon,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_showProgress(state.status))
                          StepsProgressWidget(stepCount: state.stepCount),
                        _headlineByStatus(state),
                        _captionByStatus(state),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onActivityStateChanged(WalkingState state) {
    if (state.status == ActivityStatus.COMPLETED) {
      showSuccessToast(context, 'Activity `10,000` steps completed!');
    }
  }

  Future<void> _onActivityTap(BuildContext context) async {
    if (Platform.isAndroid) {
      if (_walkingActivityStatus != PermissionStatus.granted || _allowUseGoogleFit != true) {
        await _requestAndroidAuthorization();
      }

      if (_allowUseGoogleFit == null) {
        if (mounted) {
          showInfoToast(
            context,
            'To track the steps taken, you need to install Google Fit',
          );
        }
      }

      if (_walkingActivityStatus != PermissionStatus.granted) {
        if (mounted) {
          showInfoToast(
            context,
            'To track the steps taken, you need to allow the app access to the pedometer',
          );
        }
      }

      if (_allowUseGoogleFit != true) {
        if (mounted) {
          showInfoToast(
            context,
            'To track the steps taken, you need to allow the application to integrate with Google Fit',
          );
        }
      }
    }

    if (Platform.isIOS) {
      if (_walkingActivityStatus != PermissionStatus.granted) {
        await _requestIosHealthAuthorization();
      }

      if (_walkingActivityStatus != PermissionStatus.granted) {
        if (mounted) {
          showInfoToast(
            context,
            'To track the steps taken, you need to allow the application to integrate with Health',
          );
        }
      }
    }
  }

  BoxDecoration _backgroundByStatus(BuildContext context, WalkingState state) {
    var outlineByStatus = AppColors.greyF4;

    if (Platform.isAndroid) {
      if (_walkingActivityStatus == PermissionStatus.granted) {
        if (state.status == ActivityStatus.COMPLETED) {
          outlineByStatus = Colors.green.shade100;
        } else if (_allowUseGoogleFit ?? false) {
          outlineByStatus = Colors.blue.shade100;
        }
      }
    } else {
      if (_walkingActivityStatus == PermissionStatus.granted) {
        if (state.status == ActivityStatus.COMPLETED) {
          outlineByStatus = Colors.green.shade100;
        } else {
          outlineByStatus = Colors.blue.shade100;
        }
      }
    }

    return BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      color: AppColors.greyF4,
      border: Border.all(color: outlineByStatus),
    );
  }

  Widget _headlineByStatus(WalkingState state) {
    var textByStatus = Platform.isAndroid ? 'Install Google Fit' : 'Configure';

    if (Platform.isAndroid) {
      if (_walkingActivityStatus == PermissionStatus.granted) {
        if (state.status == ActivityStatus.COMPLETED) {
          textByStatus = 'Today the goal has been achieved!';
        } else if (_allowUseGoogleFit ?? false) {
          textByStatus = '${state.stepCount} steps completed';
        } else {
          textByStatus = 'Activate\nGoogle Fit';
        }
      }
    } else {
      if (_walkingActivityStatus == PermissionStatus.granted) {
        if (state.status == ActivityStatus.COMPLETED) {
          textByStatus = 'Today the goal has been achieved!';
        } else {
          textByStatus = '${state.stepCount} steps completed';
        }
      }
    }

    return Subtitle(
      textByStatus,
      fontWeight: FontWeight.bold,
      textAlign: TextAlign.start,
    );
  }

  Widget _captionByStatus(WalkingState state) {
    var textByStatus = '';

    if (Platform.isAndroid) {
      if (_walkingActivityStatus == PermissionStatus.granted) {
        if (state.status != ActivityStatus.COMPLETED && _allowUseGoogleFit != true) {
          textByStatus =
              'Activating Google Fit will allow the app to read the steps you have taken. You can disconnect from Google Fit at any time in the app settings.';
        }
      } else {
        textByStatus = 'To set up the pedometer, you need to install Google Fit';
      }
    } else {
      if (_walkingActivityStatus != PermissionStatus.granted) {
        textByStatus = 'You need to set up synchronization of steps with the Health app';
      }
    }

    return Subtitle2(
      textByStatus,
      color: AppColors.captionText,
      textAlign: TextAlign.start,
    );
  }

  Future<void> _checkStepsAuthorization() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      const currentStatus = PermissionStatus.granted;

      try {
        // проверяем установлен ли Google Fit
        await InstalledApps.getAppInfo('com.google.android.apps.fitness');

        final allowUseGoogleFit = await HealthFactory.hasPermissions(
          [HealthDataType.STEPS],
        );

        setState(() {
          _walkingActivityStatus = currentStatus;
          _allowUseGoogleFit = allowUseGoogleFit;
        });

        if (currentStatus == PermissionStatus.granted && (allowUseGoogleFit ?? false)) {
          walkingBloc.add(const WalkingStarted());
        }
      } catch (ex, stack) {
        logger.d(ex.toString(), stack);
        setState(() {
          _walkingActivityStatus = null;
          _allowUseGoogleFit = null;
        });
        logger.e('_checkStepsAuthorization', ex, stack);
      }
    } else {
      final currentStatus = await Permission.sensors.status;
      setState(() {
        _walkingActivityStatus = currentStatus;
      });

      if (_walkingActivityStatus == PermissionStatus.granted) {
        try {
          final isRequested = await HealthKitReporter.requestAuthorization(
            <String>[QuantityType.stepCount.identifier],
            [],
          );

          walkingBloc.add(WalkingStarted(isRequested));
        } catch (ex, stack) {
          logger.e('_requestIosHealthAuthorization', ex, stack);
        }
      }
    }
  }

  Future _requestAndroidAuthorization() async {
    if (_allowUseGoogleFit == null) {
      try {
        // проверяем установлен ли Google Fit
        await InstalledApps.getAppInfo('com.google.android.apps.fitness');
      } catch (ex) {
        logger.d('no google fit');
        return;
      }
    }

    if (_walkingActivityStatus != PermissionStatus.granted) {
      final currentStatus = await Permission.activityRecognition.request();
      setState(() {
        _walkingActivityStatus = currentStatus;
      });
    }

    if (_walkingActivityStatus == PermissionStatus.granted) {
      if (_allowUseGoogleFit != true) {
        bool? allowUseGoogleFit;

        try {
          allowUseGoogleFit = await HealthFactory().requestAuthorization(
            [HealthDataType.STEPS],
          );

          if (allowUseGoogleFit == true) {
            walkingBloc.add(const WalkingStarted());
          }
        } catch (ex, stack) {
          logger.e('_requestAndroidAuthorization', ex, stack);
          allowUseGoogleFit = false;
        }

        setState(() {
          _allowUseGoogleFit = allowUseGoogleFit;
        });
      }
    }

    if (_walkingActivityStatus == PermissionStatus.granted && (_allowUseGoogleFit ?? false)) {
      walkingBloc.add(const WalkingStarted());
    }
  }

  Future<void> _requestIosHealthAuthorization() async {
    if (_walkingActivityStatus != PermissionStatus.granted) {
      final status = await Permission.sensors.request();
      setState(() {
        _walkingActivityStatus = status;
      });
    }

    if (_walkingActivityStatus == PermissionStatus.granted) {
      try {
        final isRequested = await HealthKitReporter.requestAuthorization(
          <String>[QuantityType.stepCount.identifier],
          [],
        );

        walkingBloc.add(WalkingStarted(isRequested));
      } catch (ex, stack) {
        logger.e('_requestIosHealthAuthorization', ex, stack);
      }
    }
  }

  bool _showProgress(ActivityStatus status) {
    var showProgress = false;

    if (Platform.isAndroid &&
        _walkingActivityStatus == PermissionStatus.granted &&
        (status == ActivityStatus.COMPLETED || (_allowUseGoogleFit ?? false))) {
      showProgress = true;
    } else if (Platform.isIOS && _walkingActivityStatus == PermissionStatus.granted) {
      showProgress = true;
    }

    return showProgress;
  }
}

class StepsProgressWidget extends StatelessWidget {
  final int stepCount;

  const StepsProgressWidget({required this.stepCount, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 10,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: LinearProgressIndicator(
              value: stepCount / 10000,
              backgroundColor: AppColors.greyBorder,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
