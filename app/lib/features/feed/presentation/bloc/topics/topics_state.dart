part of 'topics_bloc.dart';

@immutable
sealed class TopicsState {}

final class TopicsInitial extends TopicsState {}

final class TopicsLoading extends TopicsState {}

final class TopicsLoaded extends TopicsState {
  final List<Topic> topics;
  TopicsLoaded({required this.topics});
}

final class TopicsError extends TopicsState {
  final String message;
  TopicsError({required this.message});
}
