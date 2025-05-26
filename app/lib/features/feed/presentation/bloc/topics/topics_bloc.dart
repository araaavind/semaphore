import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/feed/domain/entities/topic.dart';
import 'package:app/features/feed/domain/usecases/list_topics.dart';
import 'package:bloc/bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';

part 'topics_event.dart';
part 'topics_state.dart';

class TopicsBloc extends Bloc<TopicsEvent, TopicsState> {
  final ListTopics _listTopics;

  TopicsBloc({
    required ListTopics listTopics,
  })  : _listTopics = listTopics,
        super(TopicsInitial()) {
    on<ListTopicsRequested>(_onListTopicsRequested);
  }

  void _onListTopicsRequested(
      ListTopicsRequested event, Emitter<TopicsState> emit) async {
    emit(TopicsLoading());
    final res = await _listTopics(NoParams());
    switch (res) {
      case Left(value: final l):
        emit(TopicsError(message: l.message));
      case Right(value: final r):
        emit(TopicsLoaded(topics: r));
    }
  }
}
