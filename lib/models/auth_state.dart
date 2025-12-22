import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const AuthState._(); // Added private constructor

  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated({
    required String token,
    required String userId,
  }) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.signupSuccess(String message) = _SignupSuccess;
  const factory AuthState.resetCodeSent(String message) = _ResetCodeSent;
  const factory AuthState.codeVerified(String message) = _CodeVerified;
  const factory AuthState.passwordResetSuccess(String message) =
      _PasswordResetSuccess;
  const factory AuthState.error(String message) = _Error;

  bool get isLoading => maybeWhen(
        loading: () => true,
        orElse: () => false,
      );

  bool get isAuthenticated => maybeWhen(
        authenticated: (_, __) => true,
        orElse: () => false,
      );
}
