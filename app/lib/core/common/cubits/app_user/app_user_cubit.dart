import 'package:app/core/common/entities/user.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_user_state.dart';

class AppUserCubit extends Cubit<AppUserState> {
  AppUserCubit() : super(AppUserInitial());

  void setUser(User user) {
    emit(AppUserLoggedIn(user));
  }

  void clearUser() {
    emit(AppUserInitial());
  }
}
