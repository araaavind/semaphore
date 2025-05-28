import 'dart:math';

import 'package:app/features/feed/domain/entities/topic.dart';
import 'package:app/features/feed/domain/usecases/list_topics.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

part 'topics_event.dart';
part 'topics_state.dart';

class TopicsBloc extends Bloc<TopicsEvent, TopicsState> {
  final ListTopics _listTopics;

  TopicsBloc({
    required ListTopics listTopics,
  })  : _listTopics = listTopics,
        super(TopicsState()) {
    on<ListTopicsRequested>(_onListTopicsRequested);
    on<SetTopicImageProviders>(_onSetTopicImageProviders);
  }

  void _onSetTopicImageProviders(
      SetTopicImageProviders event, Emitter<TopicsState> emit) {
    emit(
      state.copyWith(imageProviders: event.imageProviders),
    );
  }

  void _onListTopicsRequested(
      ListTopicsRequested event, Emitter<TopicsState> emit) async {
    emit(
      state.copyWith(
        status: TopicsStatus.loading,
      ),
    );
    final res = await _listTopics(event.fromLocal);
    switch (res) {
      case Left(value: final l):
        emit(
          state.copyWith(
            fromLocal: event.fromLocal,
            status: TopicsStatus.error,
            errorMessage: l.message,
            // If remote loading fails, keep the previous list of topics
            topics: !event.fromLocal ? state.topics : [],
          ),
        );
      case Right(value: final r):
        final topics = r
            .map((e) => e.copyWithDynamicColor(_getTopicColor(e.color)))
            .toList();
        emit(
          state.copyWith(
            status: TopicsStatus.loaded,
            topics: topics,
            fromLocal: event.fromLocal,
            errorMessage: null,
          ),
        );
    }
  }
}

Color _getTopicColor(String? color) {
  if (color == null || color.isEmpty) {
    final random = Random();
    final hue = random.nextDouble() * 360;
    return HSLColor.fromAHSL(
      0.4, // Alpha
      hue, // Random Hue
      1.0, // High Saturation (100%)
      0.5, // Medium Lightness (50%)
    ).toColor();
  }
  return HSLColor.fromColor(Color(int.parse(color.replaceAll('#', '0xFF'))))
      .withAlpha(0.4)
      .withSaturation(1.0)
      .withLightness(0.5)
      .toColor();
}
