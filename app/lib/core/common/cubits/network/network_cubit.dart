import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'network_state.dart';

class NetworkCubit extends Cubit<NetworkState> {
  NetworkCubit() : super(const NetworkState());

  void updateNetworkStatus(NetworkStatus status) {
    emit(state.copyWith(
      status: status,
    ));
  }
}
