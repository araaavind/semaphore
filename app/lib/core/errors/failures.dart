import 'package:equatable/equatable.dart';

class Failure extends Equatable {
  final String message;
  const Failure([this.message = 'An unexpected error occured']);

  @override
  List<Object> get props => [message];
}
