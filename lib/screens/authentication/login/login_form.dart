import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:noteep/widgets/custom_textfield.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final BuildContext context;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final RxBool passwordVisible;
  final bool rememberMe;
  final void Function() togglePasswordVisibility;
  final void Function() onLogin;
  final void Function() onLoginWithGoogle;

  const LoginForm({
    super.key,
    required this.context,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.passwordVisible,
    required this.rememberMe,
    required this.togglePasswordVisibility,
    required this.onLogin,
    required this.onLoginWithGoogle,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _buildTextField(
            emailController,
            AppLocalizations.of(context)!.validator_email,
            AppLocalizations.of(context)!.validator_email_hint,
            MingCuteIcons.mgc_mail_fill,
            TextInputType.emailAddress,
            TextInputAction.next,
          ),
          SizedBox(height: 20.h),
          _buildPasswordField(
            passwordController,
            AppLocalizations.of(context)!.validator_password,
            AppLocalizations.of(context)!.validator_password_hint,
            MingCuteIcons.mgc_lock_fill,
            TextInputType.text,
            TextInputAction.done,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData prefixIcon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  ) {
    return SizedBox(
      width: 320.w,
      child: CustomTextField(
        controller: controller,
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        validator: (val) {
          if (val == null || val.isEmpty) {
            return AppLocalizations.of(context)!.validator_email_required;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String label,
    String hint,
    IconData prefixIcon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  ) {
    return SizedBox(
      width: 320.w,
      child: Obx(
        () => CustomTextField(
          controller: controller,
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon,
          suffixIcon: Obx(
            () => IconButton(
              icon: Icon(
                passwordVisible.value
                    ? MingCuteIcons.mgc_eye_2_fill
                    : MingCuteIcons.mgc_eye_2_line,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              onPressed: togglePasswordVisibility,
            ),
          ),
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: !passwordVisible.value,
          validator: (val) {
            if (val == null || val.isEmpty) {
              return AppLocalizations.of(context)!.validator_password_required;
            }
            return null;
          },
        ),
      ),
    );
  }
}
