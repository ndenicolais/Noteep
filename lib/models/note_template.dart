// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import '../l10n/app_localizations.dart';
import 'note_model.dart';

class NoteTemplate {
  const NoteTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    this.content = '',
    this.checklistItems = const [],
  });

  final String id;
  final String name;
  final String description;
  final String icon; // emoji
  final NoteType type;
  final String content;
  final List<String> checklistItems;
}

/// Built-in templates, in the current UI language.
List<NoteTemplate> noteTemplates(AppLocalizations l) => [
  NoteTemplate(
    id: 'meeting_notes',
    name: l.templateMeetingName,
    description: l.templateMeetingDescription,
    icon: '📋',
    type: NoteType.note,
    content: l.templateMeetingContent,
  ),
  NoteTemplate(
    id: 'daily_journal',
    name: l.templateJournalName,
    description: l.templateJournalDescription,
    icon: '📔',
    type: NoteType.note,
    content: l.templateJournalContent,
  ),
  NoteTemplate(
    id: 'project_plan',
    name: l.templateProjectName,
    description: l.templateProjectDescription,
    icon: '🚀',
    type: NoteType.note,
    content: l.templateProjectContent,
  ),
  NoteTemplate(
    id: 'shopping_list',
    name: l.templateShoppingName,
    description: l.templateShoppingDescription,
    icon: '🛒',
    type: NoteType.checklist,
    checklistItems: l.templateShoppingItems.split('\n'),
  ),
  NoteTemplate(
    id: 'travel_packing',
    name: l.templateTravelName,
    description: l.templateTravelDescription,
    icon: '✈️',
    type: NoteType.checklist,
    checklistItems: l.templateTravelItems.split('\n'),
  ),
  NoteTemplate(
    id: 'ideas',
    name: l.templateIdeasName,
    description: l.templateIdeasDescription,
    icon: '💡',
    type: NoteType.note,
    content: l.templateIdeasContent,
  ),
];
