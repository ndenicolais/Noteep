import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noteep/screens/authentication/login/login_screen.dart';
import 'package:noteep/screens/authentication/signup/signup_screen.dart';
import 'package:noteep/widgets/custom_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(30.r),
            child: Center(
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  _buildTitle(context),
                  const Spacer(flex: 2),
                  _buildLogo(),
                  const Spacer(flex: 2),
                  _buildLoginButton(context),
                  SizedBox(height: 20.h),
                  _buildSignupButton(context),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Center(
      child: Text(
        'Welcome',
        style: GoogleFonts.exo2(
          color: Theme.of(context).colorScheme.secondary,
          fontSize: 60.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/app_logo.png',
      width: 200.w,
      height: 200.h,
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return CustomButton(
      title: AppLocalizations.of(context)!.welcome_login,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      textColor: Theme.of(context).colorScheme.primary,
      onPressed: () {
        Get.to(
          () => const LoginScreen(),
          transition: Transition.fade,
          duration: const Duration(milliseconds: 500),
        );
      },
    );
  }

  Widget _buildSignupButton(BuildContext context) {
    return CustomButton(
      title: AppLocalizations.of(context)!.welcome_signup,
      backgroundColor: Theme.of(context).colorScheme.primary,
      textColor: Theme.of(context).colorScheme.secondary,
      isOutline: true,
      onPressed: () {
        Get.to(
          () => const SignupScreen(),
          transition: Transition.fade,
          duration: const Duration(milliseconds: 500),
        );
      },
    );
  }
}
