// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../models/note_model.dart';
import '../models/note_template.dart';
import '../theme/app_font_sizes.dart';
import '../theme/app_spacing.dart';
import '../widgets/shared/app_dialogs.dart';
import '../widgets/shared/section_header.dart';

/// Shows a bottom sheet to pick a note template.
/// Returns the chosen [NoteTemplate] or null if dismissed.
Future<NoteTemplate?> showNoteTemplateSheet(BuildContext context) {
  return showAppSheet<NoteTemplate>(
    context,
    isScrollControlled: true,
    builder: (_) => const _NoteTemplateSheet(),
  );
}

class _NoteTemplateSheet extends StatelessWidget {
  const _NoteTemplateSheet();

  @override
  Widget build(BuildContext context) {
    final templates = noteTemplates(context.l10n);
    final textTemplates =
        templates.where((t) => t.type == NoteType.note).toList();
    final checklistTemplates =
        templates.where((t) => t.type == NoteType.checklist).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                context.l10n.templateChoose,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                children: [
                  _TemplateSection(
                    title: context.l10n.templateSectionNotes,
                    templates: textTemplates,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _TemplateSection(
                    title: context.l10n.templateSectionChecklists,
                    templates: checklistTemplates,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TemplateSection extends StatelessWidget {
  const _TemplateSection({required this.title, required this.templates});
  final String title;
  final List<NoteTemplate> templates;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title, muted: true, padding: SectionHeader.inlinePadding),
        ...templates.map((t) => _TemplateCard(template: t)),
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.template});
  final NoteTemplate template;

  @override
  Widget build(BuildContext context) {
    final isChecklist = template.type == NoteType.checklist;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pop(context, template),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withAlpha(180),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    template.icon,
                    style: const TextStyle(fontSize: AppFontSizes.xxl),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      template.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                isChecklist
                    ? Icons.checklist_rtl_outlined
                    : Icons.description_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
