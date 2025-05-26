part of 'topics_bloc.dart';

@immutable
sealed class TopicsEvent {}

final class ListTopicsRequested extends TopicsEvent {}
