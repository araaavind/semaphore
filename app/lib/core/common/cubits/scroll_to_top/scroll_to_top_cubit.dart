import 'package:flutter_bloc/flutter_bloc.dart';

class ScrollToTopCubit extends Cubit<bool> {
  ScrollToTopCubit() : super(false);

  void scrollToTopRequested() {
    emit(true);
  }

  void scrollToTopCompleted() {
    emit(false);
  }
}
