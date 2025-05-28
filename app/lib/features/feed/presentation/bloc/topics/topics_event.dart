part of 'topics_bloc.dart';

@immutable
sealed class TopicsEvent {}

final class ListTopicsRequested extends TopicsEvent {
  final bool fromLocal;
  ListTopicsRequested({required this.fromLocal});
}

final class SetTopicImageProviders extends TopicsEvent {
  final Map<String, ImageProvider> imageProviders;
  SetTopicImageProviders({required this.imageProviders});
}
