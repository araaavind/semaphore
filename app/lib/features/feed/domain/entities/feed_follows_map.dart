import 'package:app/features/feed/domain/entities/feed.dart';
import 'package:equatable/equatable.dart';

class FeedFollowsMap extends Equatable {
  final Feed feed;
  final bool isFollowed;

  const FeedFollowsMap({
    required this.feed,
    required this.isFollowed,
  });

  @override
  List<Object?> get props => [feed, isFollowed];
}
