part of 'sign_in_pod.dart';

extension ExtOnSignInPod on SignInPod {
  void addListeners() {
    emailController.addListener(_checkCanSubmit);
    passwordController.addListener(_checkCanSubmit);
  }

  void removeListeners() {
    emailController.removeListener(_checkCanSubmit);
    passwordController.removeListener(_checkCanSubmit);
  }
}
