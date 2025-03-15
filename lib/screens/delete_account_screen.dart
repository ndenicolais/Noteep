import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:noteep/screens/welcome_screen.dart';
import 'package:noteep/services/auth_service.dart';
import 'package:noteep/theme/app_colors.dart';
import 'package:noteep/widgets/custom_delete_dialog.dart';
import 'package:noteep/widgets/custom_toast.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  DeleteAccountScreenState createState() => DeleteAccountScreenState();
}

class DeleteAccountScreenState extends State<DeleteAccountScreen>
    with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  late AnimationController _loadingController;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(30.r),
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 40.h),
                  _buildBodyText(context),
                  SizedBox(height: 40.h),
                  _buildDeleteButton(context),
                ],
              ),
            ),
          ),
          if (_isLoading) _buildDeleteLoading(context)
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    User? user = _authService.currentUser;

    if (user != null) {
      bool confirmDelete = await _showDeleteDialog(context);

      if (confirmDelete) {
        setState(() {
          _isLoading = true;
        });

        if (!mounted) return;

        await _authService.deleteAccount();

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          showSuccessToast(
            context,
            AppLocalizations.of(context)!.toast_delete_success,
          );

          Get.to(() => const WelcomeScreen(),
              transition: Transition.fade,
              duration: const Duration(milliseconds: 500));
        }
      }
    }
  }

  Future<bool> _showDeleteDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return CustomDeleteDialog(
              title: AppLocalizations.of(context)!
                  .delete_account_screen_delete_dialog_title,
              content: AppLocalizations.of(context)!
                  .delete_account_screen_delete_dialog_text,
              onCancelPressed: () {
                Get.back(result: false);
              },
              onConfirmPressed: () {
                Get.back(result: true);
              },
            );
          },
        ) ??
        false;
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
        AppLocalizations.of(context)!.delete_account_screen_title,
        style: GoogleFonts.exo2(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.secondary,
    );
  }

  Widget _buildBodyText(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          MingCuteIcons.mgc_warning_fill,
          color: AppColors.errorColor,
          size: 100.sp,
        ),
        SizedBox(height: 40.h),
        Text(
          AppLocalizations.of(context)!.delete_account_screen_text_a,
          textAlign: TextAlign.center,
          style: GoogleFonts.exo2(
            color: Theme.of(context).colorScheme.tertiary,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          AppLocalizations.of(context)!.delete_account_screen_text_b,
          textAlign: TextAlign.center,
          style: GoogleFonts.exo2(
            color: Theme.of(context).colorScheme.tertiary,
            fontSize: 20.sp,
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          AppLocalizations.of(context)!.delete_account_screen_text_c,
          textAlign: TextAlign.center,
          style: GoogleFonts.exo2(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return SizedBox(
      width: 180.w,
      height: 80.h,
      child: ElevatedButton.icon(
        onPressed: _deleteAccount,
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.errorColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r))),
        icon: Icon(
          MingCuteIcons.mgc_delete_2_fill,
          size: 32.sp,
          color: Colors.white,
        ),
        label: Text(
          AppLocalizations.of(context)!.delete_account_screen_delete_button,
          style: GoogleFonts.exo2(
            color: AppColors.baseLight,
            fontSize: 20.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteLoading(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.7),
      child: Center(
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.5).animate(
            CurvedAnimation(
              parent: _loadingController,
              curve: Curves.easeInOut,
            ),
          ),
          child: Icon(
            MingCuteIcons.mgc_eraser_fill,
            size: 50.sp,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
