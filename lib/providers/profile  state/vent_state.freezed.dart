// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vent_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$VentState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<VentEntity> vents) loaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<VentEntity> vents)? loaded,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<VentEntity> vents)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VentStateInitial value) initial,
    required TResult Function(VentStateLoading value) loading,
    required TResult Function(VentStateLoaded value) loaded,
    required TResult Function(VentStateError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VentStateInitial value)? initial,
    TResult? Function(VentStateLoading value)? loading,
    TResult? Function(VentStateLoaded value)? loaded,
    TResult? Function(VentStateError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VentStateInitial value)? initial,
    TResult Function(VentStateLoading value)? loading,
    TResult Function(VentStateLoaded value)? loaded,
    TResult Function(VentStateError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VentStateCopyWith<$Res> {
  factory $VentStateCopyWith(VentState value, $Res Function(VentState) then) =
      _$VentStateCopyWithImpl<$Res, VentState>;
}

/// @nodoc
class _$VentStateCopyWithImpl<$Res, $Val extends VentState>
    implements $VentStateCopyWith<$Res> {
  _$VentStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$VentStateInitialImplCopyWith<$Res> {
  factory _$$VentStateInitialImplCopyWith(_$VentStateInitialImpl value,
          $Res Function(_$VentStateInitialImpl) then) =
      __$$VentStateInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$VentStateInitialImplCopyWithImpl<$Res>
    extends _$VentStateCopyWithImpl<$Res, _$VentStateInitialImpl>
    implements _$$VentStateInitialImplCopyWith<$Res> {
  __$$VentStateInitialImplCopyWithImpl(_$VentStateInitialImpl _value,
      $Res Function(_$VentStateInitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of VentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$VentStateInitialImpl implements VentStateInitial {
  const _$VentStateInitialImpl();

  @override
  String toString() {
    return 'VentState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$VentStateInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<VentEntity> vents) loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<VentEntity> vents)? loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<VentEntity> vents)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VentStateInitial value) initial,
    required TResult Function(VentStateLoading value) loading,
    required TResult Function(VentStateLoaded value) loaded,
    required TResult Function(VentStateError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VentStateInitial value)? initial,
    TResult? Function(VentStateLoading value)? loading,
    TResult? Function(VentStateLoaded value)? loaded,
    TResult? Function(VentStateError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VentStateInitial value)? initial,
    TResult Function(VentStateLoading value)? loading,
    TResult Function(VentStateLoaded value)? loaded,
    TResult Function(VentStateError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class VentStateInitial implements VentState {
  const factory VentStateInitial() = _$VentStateInitialImpl;
}

/// @nodoc
abstract class _$$VentStateLoadingImplCopyWith<$Res> {
  factory _$$VentStateLoadingImplCopyWith(_$VentStateLoadingImpl value,
          $Res Function(_$VentStateLoadingImpl) then) =
      __$$VentStateLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$VentStateLoadingImplCopyWithImpl<$Res>
    extends _$VentStateCopyWithImpl<$Res, _$VentStateLoadingImpl>
    implements _$$VentStateLoadingImplCopyWith<$Res> {
  __$$VentStateLoadingImplCopyWithImpl(_$VentStateLoadingImpl _value,
      $Res Function(_$VentStateLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of VentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$VentStateLoadingImpl implements VentStateLoading {
  const _$VentStateLoadingImpl();

  @override
  String toString() {
    return 'VentState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$VentStateLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<VentEntity> vents) loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<VentEntity> vents)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<VentEntity> vents)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VentStateInitial value) initial,
    required TResult Function(VentStateLoading value) loading,
    required TResult Function(VentStateLoaded value) loaded,
    required TResult Function(VentStateError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VentStateInitial value)? initial,
    TResult? Function(VentStateLoading value)? loading,
    TResult? Function(VentStateLoaded value)? loaded,
    TResult? Function(VentStateError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VentStateInitial value)? initial,
    TResult Function(VentStateLoading value)? loading,
    TResult Function(VentStateLoaded value)? loaded,
    TResult Function(VentStateError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class VentStateLoading implements VentState {
  const factory VentStateLoading() = _$VentStateLoadingImpl;
}

/// @nodoc
abstract class _$$VentStateLoadedImplCopyWith<$Res> {
  factory _$$VentStateLoadedImplCopyWith(_$VentStateLoadedImpl value,
          $Res Function(_$VentStateLoadedImpl) then) =
      __$$VentStateLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<VentEntity> vents});
}

/// @nodoc
class __$$VentStateLoadedImplCopyWithImpl<$Res>
    extends _$VentStateCopyWithImpl<$Res, _$VentStateLoadedImpl>
    implements _$$VentStateLoadedImplCopyWith<$Res> {
  __$$VentStateLoadedImplCopyWithImpl(
      _$VentStateLoadedImpl _value, $Res Function(_$VentStateLoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of VentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vents = null,
  }) {
    return _then(_$VentStateLoadedImpl(
      null == vents
          ? _value._vents
          : vents // ignore: cast_nullable_to_non_nullable
              as List<VentEntity>,
    ));
  }
}

/// @nodoc

class _$VentStateLoadedImpl implements VentStateLoaded {
  const _$VentStateLoadedImpl(final List<VentEntity> vents) : _vents = vents;

  final List<VentEntity> _vents;
  @override
  List<VentEntity> get vents {
    if (_vents is EqualUnmodifiableListView) return _vents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_vents);
  }

  @override
  String toString() {
    return 'VentState.loaded(vents: $vents)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VentStateLoadedImpl &&
            const DeepCollectionEquality().equals(other._vents, _vents));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_vents));

  /// Create a copy of VentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VentStateLoadedImplCopyWith<_$VentStateLoadedImpl> get copyWith =>
      __$$VentStateLoadedImplCopyWithImpl<_$VentStateLoadedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<VentEntity> vents) loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(vents);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<VentEntity> vents)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(vents);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<VentEntity> vents)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(vents);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VentStateInitial value) initial,
    required TResult Function(VentStateLoading value) loading,
    required TResult Function(VentStateLoaded value) loaded,
    required TResult Function(VentStateError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VentStateInitial value)? initial,
    TResult? Function(VentStateLoading value)? loading,
    TResult? Function(VentStateLoaded value)? loaded,
    TResult? Function(VentStateError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VentStateInitial value)? initial,
    TResult Function(VentStateLoading value)? loading,
    TResult Function(VentStateLoaded value)? loaded,
    TResult Function(VentStateError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class VentStateLoaded implements VentState {
  const factory VentStateLoaded(final List<VentEntity> vents) =
      _$VentStateLoadedImpl;

  List<VentEntity> get vents;

  /// Create a copy of VentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VentStateLoadedImplCopyWith<_$VentStateLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$VentStateErrorImplCopyWith<$Res> {
  factory _$$VentStateErrorImplCopyWith(_$VentStateErrorImpl value,
          $Res Function(_$VentStateErrorImpl) then) =
      __$$VentStateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$VentStateErrorImplCopyWithImpl<$Res>
    extends _$VentStateCopyWithImpl<$Res, _$VentStateErrorImpl>
    implements _$$VentStateErrorImplCopyWith<$Res> {
  __$$VentStateErrorImplCopyWithImpl(
      _$VentStateErrorImpl _value, $Res Function(_$VentStateErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of VentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$VentStateErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$VentStateErrorImpl implements VentStateError {
  const _$VentStateErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'VentState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VentStateErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of VentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VentStateErrorImplCopyWith<_$VentStateErrorImpl> get copyWith =>
      __$$VentStateErrorImplCopyWithImpl<_$VentStateErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<VentEntity> vents) loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<VentEntity> vents)? loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<VentEntity> vents)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VentStateInitial value) initial,
    required TResult Function(VentStateLoading value) loading,
    required TResult Function(VentStateLoaded value) loaded,
    required TResult Function(VentStateError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VentStateInitial value)? initial,
    TResult? Function(VentStateLoading value)? loading,
    TResult? Function(VentStateLoaded value)? loaded,
    TResult? Function(VentStateError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VentStateInitial value)? initial,
    TResult Function(VentStateLoading value)? loading,
    TResult Function(VentStateLoaded value)? loaded,
    TResult Function(VentStateError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class VentStateError implements VentState {
  const factory VentStateError(final String message) = _$VentStateErrorImpl;

  String get message;

  /// Create a copy of VentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VentStateErrorImplCopyWith<_$VentStateErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
