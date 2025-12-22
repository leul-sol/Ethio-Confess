import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ethioconfess/models/popular_entity.dart';

part 'vent_state.freezed.dart';

@freezed
class VentState with _$VentState {
  const factory VentState.initial() = VentStateInitial;
  const factory VentState.loading() = VentStateLoading;
  const factory VentState.loaded(List<VentEntity> vents) = VentStateLoaded;
  const factory VentState.error(String message) = VentStateError;
}
