import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streamcoy/core/core.dart';
import 'sign_in_state.dart';

part 'ext_on_sign_in_pod.dart';

final _signInProvider = NotifierProvider.autoDispose<SignInPod, SignInState>(
  SignInPod.new,
  name: 'SignInPod',
);

class SignInPod extends Notifier<SignInState>
    with TextEditingControllerFactoryMixin {
  static final me = _signInProvider;

  late final emailController = useTextEditingController();
  late final passwordController = useTextEditingController();

  @override
  SignInState build() {
    ref.onDispose(_dispose);
    addListeners();
    return const SignInState();
  }

  void setLoading(bool v) => state = state.copyWith(isLoading: v);

  Future<bool> submit() async {
    setLoading(true);
    await Future.delayed(const Duration(milliseconds: 400));
    setLoading(false);
    return true;
  }

  void _checkCanSubmit() {
    final valid =
        emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    if (state.canSubmit == valid) return;
    state = state.copyWith(canSubmit: valid);
  }

  void _dispose() {
    removeListeners();
    disposeControllers();
  }
}
