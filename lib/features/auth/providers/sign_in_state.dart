import 'package:equatable/equatable.dart';

class SignInState extends Equatable {
  final bool isLoading;
  final bool isPasswordVisible;
  final bool canSubmit;
  final bool rememberMe;
  final String? errorMessage;

  const SignInState({
    this.isLoading = false,
    this.isPasswordVisible = false,
    this.canSubmit = false,
    this.rememberMe = false,
    this.errorMessage,
  });

  SignInState copyWith({
    bool? isLoading,
    bool? isPasswordVisible,
    bool? canSubmit,
    bool? rememberMe,
    String? errorMessage,
  }) {
    return SignInState(
      isLoading: isLoading ?? this.isLoading,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      canSubmit: canSubmit ?? this.canSubmit,
      rememberMe: rememberMe ?? this.rememberMe,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isPasswordVisible,
    canSubmit,
    rememberMe,
    errorMessage,
  ];
}
