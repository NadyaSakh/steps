part of 'walking_bloc.dart';

enum ActivityStatus {
  UNKNOWN,
  AVAILABLE,
  COMPLETED,
  COMPLETING,
  FAILED,
}

class WalkingState extends Equatable {
  final ActivityStatus status;
  final int stepCount;
  final DateTime? lastSyncDate;
  final List<String>? events;

  const WalkingState({
    this.status = ActivityStatus.UNKNOWN,
    this.stepCount = 0,
    this.lastSyncDate,
    this.events,
  });

  WalkingState copyWith({
    ActivityStatus? status,
    int? stepCount,
    DateTime? lastSyncDate,
    List<String>? events,
  }) {
    return WalkingState(
      status: status ?? this.status,
      stepCount: stepCount ?? this.stepCount,
      lastSyncDate: lastSyncDate ?? this.lastSyncDate,
      events: events ?? this.events,
    );
  }

  @override
  List<Object?> get props => [
        status,
        stepCount,
        lastSyncDate,
        events,
      ];
}
