import 'package:freezed_annotation/freezed_annotation.dart';

part 'reply_state.freezed.dart';

@freezed
class ReplyState with _$ReplyState {
  const ReplyState._(); // Private constructor

  const factory ReplyState.initial() = _Initial;
  const factory ReplyState.loading() = _Loading;
  const factory ReplyState.success() = _Success;
  const factory ReplyState.error(String message) = _Error;

  bool get isLoading => maybeWhen(
        loading: () => true,
        orElse: () => false,
      );

  bool get isSuccess => maybeWhen(
        success: () => true,
        orElse: () => false,
      );
}
