import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/timer.class.dart';



class TimerCubit extends Cubit<TimerState?> {
  TimerCubit._() : super(null);

  static final instance = TimerCubit._();

  void setTimerCubit({required int workMinutes, required int restMinutes}) {
    emit(TimerState.start(workMinutes: workMinutes, restMinutes: restMinutes));
  }

  void setPause() {
    emit(state?.paused());
  }

  void setResume() {
    emit(state?.resumed());
  }

}