part of 'topics_bloc.dart';

enum TopicsStatus {
  initial,
  loading,
  loaded,
  error,
  preloaded,
}

class TopicsState extends Equatable {
  final bool fromLocal;
  final TopicsStatus status;
  final String? errorMessage;
  final List<Topic> topics;
  final Map<String, ImageProvider> imageProviders;

  TopicsState({
    this.fromLocal = false,
    this.status = TopicsStatus.initial,
    this.errorMessage,
    this.topics = const [],
    this.imageProviders = const {},
  });

  TopicsState copyWith({
    bool? fromLocal,
    TopicsStatus? status,
    String? errorMessage,
    List<Topic>? topics,
    Map<String, ImageProvider>? imageProviders,
  }) {
    return TopicsState(
      fromLocal: fromLocal ?? this.fromLocal,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      topics: topics ?? this.topics,
      imageProviders: imageProviders ?? this.imageProviders,
    );
  }

  @override
  List<Object?> get props =>
      [fromLocal, status, errorMessage, topics, imageProviders];
}
