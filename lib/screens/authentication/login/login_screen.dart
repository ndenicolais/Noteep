import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:noteep/screens/authentication/login/login_controller.dart';
import 'package:noteep/screens/authentication/login/login_form.dart';
import 'package:noteep/screens/authentication/reset_password/reset_password_screen.dart';
import 'package:noteep/screens/authentication/signup/signup_screen.dart';
import 'package:noteep/screens/home_screen.dart';
import 'package:noteep/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final LoginController controller = Get.put(LoginController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _checkRememberMe();
  }

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
                  LoginForm(
                    context: context,
                    formKey: _formKey,
                    emailController: controller.emailController,
                    passwordController: controller.passwordController,
                    passwordVisible: controller.passwordVisible,
                    rememberMe: controller.rememberMe.value,
                    togglePasswordVisibility:
                        controller.togglePasswordVisibility,
                    onLogin: () => controller.login(context, _formKey),
                    onLoginWithGoogle: () =>
                        controller.loginWithGoogle(context),
                  ),
                  SizedBox(
                    width: 320.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildRememberMeCheckbox(context, controller),
                        _buildForgotPasswordText(context),
                      ],
                    ),
                  ),
                  _buildButtons(context, controller),
                  _buildSignupText(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('remember_me') ?? false) {
      Get.to(() => const HomeScreen(),
          transition: Transition.fade,
          duration: const Duration(milliseconds: 500));
    }
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
        AppLocalizations.of(context)!.login_screen_title,
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

  Widget _buildButtons(BuildContext context, LoginController controller) {
    final double dividerIndent = ScreenUtil().screenWidth > 600 ? 220.w : 60.w;
    return Column(
      children: [
        CustomButton(
          title: AppLocalizations.of(context)!.login_screen_text,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          textColor: Theme.of(context).colorScheme.primary,
          onPressed: () => controller.login(context, _formKey),
        ),
        SizedBox(height: 20.h),
        Divider(
          thickness: 1,
          indent: dividerIndent,
          endIndent: dividerIndent,
          color: Theme.of(context).colorScheme.secondary,
        ),
        SizedBox(height: 20.h),
        GestureDetector(
          onTap: () => controller.loginWithGoogle(context),
          child: Image.asset(
            'assets/images/img_google.png',
            width: 40.w,
          ),
        ),
      ],
    );
  }

  Widget _buildRememberMeCheckbox(
      BuildContext context, LoginController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.scale(
          scale: 1.4.r,
          child: Obx(
            () => Checkbox(
              value: controller.rememberMe.value,
              onChanged: (value) => controller.rememberMe.value = value!,
              checkColor: Theme.of(context).colorScheme.primary,
              activeColor: Theme.of(context).colorScheme.secondary,
              shape: const CircleBorder(),
              side: BorderSide(color: Theme.of(context).colorScheme.tertiary),
            ),
          ),
        ),
        Text(
          AppLocalizations.of(context)!.login_screen_remember,
          style: GoogleFonts.exo2(
            color: Theme.of(context).colorScheme.tertiary,
            fontSize: 16.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordText(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: AppLocalizations.of(context)!.login_screen_password,
        style: GoogleFonts.exo2(
          color: Theme.of(context).colorScheme.secondary,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => Get.off(
                () => const ResetPasswordScreen(),
                transition: Transition.fade,
                duration: const Duration(milliseconds: 500),
              ),
      ),
    );
  }

  Widget _buildSignupText(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: AppLocalizations.of(context)!.login_screen_account,
        style: GoogleFonts.exo2(
          color: Theme.of(context).colorScheme.tertiary,
          fontSize: 14.sp,
        ),
        children: [
          TextSpan(
            text: AppLocalizations.of(context)!.login_screen_signup,
            style: GoogleFonts.exo2(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => Get.off(
                    () => const SignupScreen(),
                    transition: Transition.fade,
                    duration: const Duration(milliseconds: 500),
                  ),
          ),
        ],
      ),
    );
  }
}
