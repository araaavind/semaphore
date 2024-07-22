import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'network_state.dart';

class NetworkCubit extends Cubit<NetworkState> {
  NetworkCubit() : super(const NetworkState());

  void updateNetworkStatus(bool isConnected) {
    if (isConnected) {
      emit(state.copyWith(
        status: NetworkStatus.connected,
      ));
    } else {
      emit(state.copyWith(
        status: NetworkStatus.disconnected,
      ));
    }
  }
}
