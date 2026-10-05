// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

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

/// Built-in templates
const kNoteTemplates = <NoteTemplate>[
  NoteTemplate(
    id: 'meeting_notes',
    name: 'Note riunione',
    description: 'Struttura per prendere appunti durante una riunione',
    icon: '📋',
    type: NoteType.note,
    content:
        '## Riunione del [DATA]\n\n'
        '**Partecipanti:**\n- \n\n'
        '**Ordine del giorno:**\n1. \n\n'
        '**Punti discussi:**\n\n'
        '**Decisioni prese:**\n\n'
        '**Azioni da fare:**\n- \n\n'
        '**Prossima riunione:** ',
  ),
  NoteTemplate(
    id: 'daily_journal',
    name: 'Diario giornaliero',
    description: 'Traccia i tuoi pensieri e obiettivi del giorno',
    icon: '📔',
    type: NoteType.note,
    content:
        '## [DATA]\n\n'
        '**Come mi sento oggi:**\n\n'
        '**Tre cose per cui sono grato:**\n'
        '1. \n2. \n3. \n\n'
        '**Obiettivi di oggi:**\n\n'
        '**Riflessioni della giornata:**\n',
  ),
  NoteTemplate(
    id: 'project_plan',
    name: 'Piano di progetto',
    description: 'Organizza obiettivi, milestones e risorse di un progetto',
    icon: '🚀',
    type: NoteType.note,
    content:
        '## Progetto: [NOME]\n\n'
        '**Obiettivo:**\n\n'
        '**Scadenza:**\n\n'
        '**Milestones:**\n'
        '- [ ] \n'
        '- [ ] \n\n'
        '**Risorse necessarie:**\n\n'
        '**Note:**\n',
  ),
  NoteTemplate(
    id: 'shopping_list',
    name: 'Lista spesa',
    description: 'Lista della spesa con caselle di controllo',
    icon: '🛒',
    type: NoteType.checklist,
    checklistItems: ['Frutta e verdura', 'Latte', 'Pane', 'Uova'],
  ),
  NoteTemplate(
    id: 'travel_packing',
    name: 'Lista viaggio',
    description: 'Non dimenticare nulla per il tuo viaggio',
    icon: '✈️',
    type: NoteType.checklist,
    checklistItems: [
      'Passaporto / Documenti',
      'Caricabatterie',
      'Vestiti',
      'Prodotti da toilette',
      'Medicinali',
      'Contanti / Carte',
    ],
  ),
  NoteTemplate(
    id: 'ideas',
    name: 'Brainstorming idee',
    description: 'Spazio libero per raccogliere idee',
    icon: '💡',
    type: NoteType.note,
    content:
        '## Idea: [TITOLO]\n\n'
        '**Descrizione:**\n\n'
        '**Pro:**\n- \n\n'
        '**Contro:**\n- \n\n'
        '**Prossimi passi:**\n',
  ),
];
