import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileState with _$ProfileState {
  const ProfileState._(); // Added private constructor

  const factory ProfileState.initial() = _Initial;
  const factory ProfileState.loading() = _Loading;
  const factory ProfileState.success(String message) = _Success;
  const factory ProfileState.error(String message) = _Error;

  bool get isLoading => maybeWhen(
        loading: () => true,
        orElse: () => false,
      );
} 