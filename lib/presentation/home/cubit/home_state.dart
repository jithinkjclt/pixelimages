part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  final List<Photo> images;
  final bool isLoadingMore;

  HomeLoaded({required this.images, this.isLoadingMore = false});
}

final class HomeError extends HomeState {
  final String errorMessage;

  HomeError({required this.errorMessage});
}
