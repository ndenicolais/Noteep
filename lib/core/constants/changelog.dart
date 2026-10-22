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
    version: '2.0.3',
    bullets: [
      'Nuova icona dell\'app: la lampadina con la spunta su sfondo scuro, che si adatta alla forma scelta dal launcher e ai temi colore di Android 13 e successivi.',
      'La schermata di accesso e registrazione mostra il nuovo logo dell\'app.',
    ],
  ),
  ChangelogEntry(
    version: '2.0.2',
    bullets: [
      'Modalità offline: le modifiche fatte senza connessione vengono salvate sul dispositivo e inviate appena torni online, con un avviso finché restano in attesa. Anche sul web i dati restano disponibili offline.',
      'Aspetto più uniforme: intestazioni di sezione, voci delle impostazioni, elementi di archivio e cestino ed etichette hanno ora lo stesso stile in tutta l\'app, e le conferme di eliminazione usano sempre il pulsante rosso.',
    ],
  ),
  ChangelogEntry(
    version: '2.0.1',
    bullets: [
      'Durante il primo caricamento di note e attività compare un\'anteprima della lista al posto della rotellina, con un passaggio più morbido tra caricamento, lista e schermata vuota.',
      'Nuova griglia della Home "a mattoncini": ogni nota occupa solo lo spazio che le serve, senza vuoti tra le note corte e senza tagliare quelle lunghe.',
      'Toccando la notifica di un promemoria si apre direttamente la nota, l\'attività o l\'evento collegato, anche ad app chiusa.',
      'Animazioni più fluide: la nota si espande dalla sua card quando la apri e il passaggio tra le sezioni del menu avviene in dissolvenza. Con le animazioni ridotte del sistema restano disattivate.',
      'Accessibilità: con TalkBack ogni nota si legge per intero e le azioni rapide (fissa, archivia, blocca, cestino, sposta) sono nel menu Azioni; con il testo di sistema molto grande schede e campi non vengono più tagliati, e i pannelli dal basso non finiscono sotto la barra di navigazione.',
    ],
  ),
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
      'Scorri un\'attività verso destra per completarla o verso sinistra per spostarla nel cestino; in vista elenco, scorri una nota verso destra per archiviarla o verso sinistra per cestinarla.',
      'Selettori di data e ora, menu di sistema e date tutti in italiano.',
      'Se l\'avvio non riesce, al posto di una schermata bianca compare un messaggio con il pulsante Riprova.',
      'Ripristino dei backup automatici: in Impostazioni, apri l\'elenco dei backup e tocca quello da ripristinare.',
      'Importare un backup completo ora elimina davvero note, attività ed eventi che non ne fanno parte, invece di farli ricomparire al riavvio.',
      'Calendario ICS: gli eventi ricorrenti esportati mantengono la data di fine, quelli importati non perdono più l\'ultima ripetizione a cavallo del cambio d\'ora, gli orari con fuso esplicito restano corretti e il testo con barre rovesciate viene letto bene.',
    ],
  ),
];
