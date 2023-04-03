part of 'walking_bloc.dart';

@immutable
abstract class WalkingEvent {
  const WalkingEvent();
}

class WalkingStarted extends WalkingEvent {
  final bool? isIosMode;

  const WalkingStarted([this.isIosMode]);
}

class WalkingInitEvent extends WalkingEvent {
  final int steps;

  const WalkingInitEvent(this.steps);
}

class WalkingStepsChanged extends WalkingEvent {
  final int steps;

  const WalkingStepsChanged(this.steps);
}

class WalkingCompleteEvent extends WalkingEvent {
  final int steps;

  const WalkingCompleteEvent(this.steps);
}

class WalkingResetEvent extends WalkingEvent {
  final int steps;
  final DateTime syncDate;
  final ActivityStatus? status;

  const WalkingResetEvent(this.steps, this.syncDate, {this.status});
}

class WalkingDebugEvent extends WalkingEvent {
  final String event;

  const WalkingDebugEvent(this.event);
}
