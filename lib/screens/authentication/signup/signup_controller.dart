import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:noteep/models/user_model.dart';
import 'package:noteep/services/auth_service.dart';
import 'package:noteep/screens/home_screen.dart';
import 'package:noteep/widgets/custom_toast.dart';

class SignupController extends GetxController {
  final AuthService _authService = AuthService();
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var passwordVisible = false.obs;

  void togglePasswordVisibility() {
    passwordVisible.value = !passwordVisible.value;
  }

  Future<void> register(
      BuildContext context, GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      if (nameController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty) {
        UserModel user = UserModel(
          userEmail: emailController.text,
          userName: nameController.text,
        );

        User? registeredUser = await _authService.signUpWithEmailPassword(
          user,
          nameController.text,
          emailController.text,
          passwordController.text,
        );

        if (registeredUser != null) {
          if (context.mounted) {
            showSuccessToast(
              context,
              '${AppLocalizations.of(context)!.toast_signup_welcome}${user.userName}',
            );
          }
          Get.to(() => const HomeScreen(),
              transition: Transition.fade,
              duration: const Duration(milliseconds: 500));
        }
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (context.mounted) {
        if (e is Exception && errorMessage.contains("email_already_register")) {
          errorMessage = AppLocalizations.of(context)!
              .signup_toast_error_email_already_register;
        }
      }

      if (context.mounted) {
        showErrorToast(
          context,
          errorMessage,
        );
      }
    }
  }
}
