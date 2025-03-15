import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:noteep/screens/authentication/login/login_screen.dart';
import 'package:noteep/screens/authentication/signup/signup_controller.dart';
import 'package:noteep/screens/authentication/signup/signup_form.dart';
import 'package:noteep/widgets/custom_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final SignupController controller = Get.put(SignupController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(30.r),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20.h,
                children: [
                  _buildLogo(),
                  SizedBox(height: 20.h),
                  SignupForm(
                    context: context,
                    formKey: _formKey,
                    nameController: controller.nameController,
                    emailController: controller.emailController,
                    passwordController: controller.passwordController,
                    passwordVisible: controller.passwordVisible,
                    togglePasswordVisibility:
                        controller.togglePasswordVisibility,
                  ),
                  _buildButton(context, controller),
                  _buildLoginText(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          MingCuteIcons.mgc_arrow_left_line,
          color: Theme.of(context).colorScheme.secondary,
        ),
        onPressed: () {
          Get.back();
        },
      ),
      title: Text(
        AppLocalizations.of(context)!.signup_screen_title,
        style: GoogleFonts.exo2(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.secondary,
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/app_logo.png',
      width: 180.w,
      height: 180.h,
    );
  }

  Widget _buildButton(BuildContext context, SignupController controller) {
    return CustomButton(
      title: AppLocalizations.of(context)!.signup_screen_text,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      textColor: Theme.of(context).colorScheme.primary,
      onPressed: () => controller.register(context, _formKey),
    );
  }

  Widget _buildLoginText(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: AppLocalizations.of(context)!.signup_screen_account,
        style: GoogleFonts.exo2(
          color: Theme.of(context).colorScheme.tertiary,
          fontSize: 16.sp,
        ),
        children: [
          TextSpan(
            text: AppLocalizations.of(context)!.signup_screen_login,
            style: GoogleFonts.exo2(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => Get.off(
                    () => const LoginScreen(),
                    transition: Transition.fade,
                    duration: const Duration(milliseconds: 500),
                  ),
          ),
        ],
      ),
    );
  }
}
