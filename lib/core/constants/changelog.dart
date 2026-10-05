// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

class ChangelogEntry {
  const ChangelogEntry({required this.version, required this.bullets});

  final String version;
  final List<String> bullets;
}

/// Newest version first.
const List<ChangelogEntry> changelogEntries = [
  ChangelogEntry(
    version: '2.0.0',
    bullets: [
      'App completamente ridisegnata: note, attività e calendario in un unico posto, sincronizzati sul tuo account.',
      'Note con stili personalizzati, Markdown, liste di controllo, note audio, collegamenti tra note e 6 modelli pronti.',
      'Note protette con impronta digitale o sblocco del dispositivo.',
      'Attività con elenchi, sottoattività, scadenze, ricorrenze e attività speciali.',
      'Nuovo calendario con vista giorno, settimana, mese, anno e programma, compleanni e onomastici, importazione ed esportazione ICS.',
      'Promemoria per note, attività ed eventi, con una schermata dedicata.',
      'Etichette, archivio e cestino con eliminazione automatica dopo 7 giorni.',
      'Statistiche, esportazione delle note in PDF, TXT, JSON, CSV e HTML, backup manuali e automatici.',
      'Widget per la schermata Home di Android.',
      'Pulsante "Annulla" dopo aver spostato nel cestino o archiviato note, attività ed eventi.',
      'Eliminare una nota o un\'attività dall\'editor ora la sposta nel cestino invece di cancellarla definitivamente.',
      'Trascina verso il basso su note e attività per aggiornarle, ad esempio dopo un errore di connessione o modifiche fatte da un altro dispositivo.',
      'Pulsante "Riprova" quando la sincronizzazione non riesce e "Crea la prima nota" quando non ne hai ancora.',
      'Selettori di data e ora, menu di sistema e date tutti in italiano.',
      'Se l\'avvio non riesce, al posto di una schermata bianca compare un messaggio con il pulsante Riprova.',
    ],
  ),
];
