// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/l10n.dart';
import '../providers/settings/ui_provider.dart';
import '../theme/app_spacing.dart';
import '../widgets/shared/app_logo.dart';

class _OnboardingPage {
  const _OnboardingPage(this.icon, this.title, this.body);

  /// Null shows the app logo instead of an icon.
  final IconData? icon;
  final String Function(AppLocalizations l) title;
  final String Function(AppLocalizations l) body;
}

final _pages = [
  _OnboardingPage(
    null,
    (l) => l.onboardingWelcomeTitle,
    (l) => l.onboardingWelcomeBody,
  ),
  _OnboardingPage(
    Icons.note_outlined,
    (l) => l.onboardingNotesTitle,
    (l) => l.onboardingNotesBody,
  ),
  _OnboardingPage(
    Icons.task_alt_outlined,
    (l) => l.onboardingTasksTitle,
    (l) => l.onboardingTasksBody,
  ),
  _OnboardingPage(
    Icons.calendar_month_outlined,
    (l) => l.onboardingCalendarTitle,
    (l) => l.onboardingCalendarBody,
  ),
  _OnboardingPage(
    Icons.notifications_active_outlined,
    (l) => l.onboardingRemindersTitle,
    (l) => l.onboardingRemindersBody,
  ),
];

/// Swipeable introduction to the app. Shown before the login on first
/// launch; [replay] opens it from Info app, where finishing just pops it.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.replay = false});

  final bool replay;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    if (widget.replay) {
      Navigator.pop(context);
    } else {
      ref.read(onboardingSeenProvider.notifier).set(true);
    }
  }

  void _next() {
    if (_isLast) return _finish();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(_index + 1);
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: AnimatedOpacity(
                  opacity: _isLast ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: _isLast ? null : _finish,
                    child: Text(context.l10n.onboardingSkip),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _PageContent(_pages[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    width: i == _index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _index ? cs.primary : cs.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(
                    _isLast
                        ? context.l10n.onboardingStart
                        : context.l10n.onboardingNext,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent(this.page);

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxl),
            if (page.icon == null)
              const AppLogo(size: 120)
            else
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(page.icon, size: 56, color: cs.onPrimaryContainer),
              ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              page.title(context.l10n),
              textAlign: TextAlign.center,
              style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              page.body(context.l10n),
              textAlign: TextAlign.center,
              style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
