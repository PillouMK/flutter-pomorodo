
class TimerState {
  TimerState.start({
    required this.workMinutes,
    required this.restMinutes,
  })  : startedAt = DateTime.now(),
        pausedAt = null,
        sessionCount = 1,
        totalWorkDuration = 0;

  TimerState._({
    required this.startedAt,
    required this.pausedAt,
    required this.workMinutes,
    required this.restMinutes,
    required this.sessionCount,
    required this.totalWorkDuration,
  });

  final DateTime startedAt;
  final DateTime? pausedAt;
  final int workMinutes;
  final int restMinutes;
  final int sessionCount; // Nombre de sessions commencées
  int totalWorkDuration; // Durée totale de travail en minutes

  TimerState start() {
    return TimerState._(
      startedAt: DateTime.now(),
      pausedAt: null,
      workMinutes: workMinutes,
      restMinutes: restMinutes,
      sessionCount: 1,
      totalWorkDuration: 0
    );
  }

  TimerState paused() {
    return TimerState._(
      startedAt: startedAt,
      pausedAt: DateTime.now(),
      workMinutes: workMinutes,
      restMinutes: restMinutes,
      sessionCount: sessionCount,
      totalWorkDuration: totalWorkDuration,
    );
  }

  TimerState resumed() {
    return pausedAt == null
        ? this
        : TimerState._(
          startedAt: startedAt.add(DateTime.now().difference(pausedAt!)),
          pausedAt: null,
          workMinutes: workMinutes,
          restMinutes: restMinutes,
          sessionCount: sessionCount,
          totalWorkDuration: totalWorkDuration,
          );
  }

  Duration get timeElapsed => pausedAt == null
      ? DateTime.now().difference(startedAt)
      : pausedAt!.difference(startedAt);



  bool get isRunning => pausedAt == null;

  bool get working {
    final minutesElapsed = timeElapsed.inMinutes;
    final fullStepMinutes = workMinutes + restMinutes;

    final currentFullStepMinutes = minutesElapsed % fullStepMinutes;

    return currentFullStepMinutes < workMinutes;
  }

  Duration get durationOfCurrentStep =>
      Duration(minutes: working ? workMinutes : restMinutes);

  Duration get timeElapsedSinceLastStep {
    final millisecondsElapsedSinceLastWorkStart =
        timeElapsed.inMilliseconds % ((workMinutes + restMinutes) * 60 * 1000);
    if (millisecondsElapsedSinceLastWorkStart > (workMinutes * 60 * 1000)) {
      // The work step is finished
      return Duration(
        milliseconds:
        millisecondsElapsedSinceLastWorkStart - (workMinutes * 60 * 1000),
      );
    } else {
      // The work step is live
      return Duration(milliseconds: millisecondsElapsedSinceLastWorkStart);
    }
  }

  Duration get nextStepIn {
    final left = durationOfCurrentStep - timeElapsedSinceLastStep;
    if (left.isNegative) return Duration.zero;
    return left;
  }
}