class TimerState {
  TimerState.start({required this.workMinutes, required this.restMinutes})
      : startedAt = DateTime.now(),
        pausedAt = null,
        working = true;

  TimerState._({
    required this.startedAt,
    required this.pausedAt,
    required this.workMinutes,
    required this.restMinutes,
    required this.working,
  });

  final DateTime startedAt;
  final DateTime? pausedAt;
  final int workMinutes;
  final int restMinutes;
  final bool working;

  TimerState start() {
    return TimerState._(
      startedAt: DateTime.now(),
      pausedAt: null,
      workMinutes: workMinutes,
      restMinutes: restMinutes,
      working: working,
    );
  }

  TimerState paused() {
    return TimerState._(
      startedAt: startedAt,
      pausedAt: DateTime.now(),
      workMinutes: workMinutes,
      restMinutes: restMinutes,
      working: working,
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
          working: working,
          );
  }


  Duration get timeElapsed => pausedAt == null
      ? DateTime.now().difference(startedAt)
      : pausedAt!.difference(startedAt);

  Duration get timeLeft {
    final left = duration - timeElapsed;
    if (left.isNegative) return Duration.zero;
    return left;
  }

  Duration get duration =>
      Duration(minutes: working ? workMinutes : restMinutes);

  bool get isRunning => pausedAt == null;
}