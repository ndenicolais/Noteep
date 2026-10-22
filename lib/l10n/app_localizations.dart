import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @settingsAppearanceTitle.
  ///
  /// In it, this message translates to:
  /// **'Aspetto'**
  String get settingsAppearanceTitle;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In it, this message translates to:
  /// **'Sistema'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In it, this message translates to:
  /// **'Chiaro'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In it, this message translates to:
  /// **'Scuro'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In it, this message translates to:
  /// **'Lingua'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In it, this message translates to:
  /// **'Lingua del sistema'**
  String get settingsLanguageSystem;

  /// No description provided for @changelog_dialog_title.
  ///
  /// In it, this message translates to:
  /// **'Novità'**
  String get changelog_dialog_title;

  /// No description provided for @changelog_dialog_close.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get changelog_dialog_close;

  /// No description provided for @changelog_section_added.
  ///
  /// In it, this message translates to:
  /// **'Novità'**
  String get changelog_section_added;

  /// No description provided for @changelog_section_improved.
  ///
  /// In it, this message translates to:
  /// **'Miglioramenti'**
  String get changelog_section_improved;

  /// No description provided for @changelog_section_fixed.
  ///
  /// In it, this message translates to:
  /// **'Correzioni'**
  String get changelog_section_fixed;

  /// No description provided for @changelog_section_security.
  ///
  /// In it, this message translates to:
  /// **'Sicurezza'**
  String get changelog_section_security;

  /// No description provided for @changelog_v2_0_0_bullet_1.
  ///
  /// In it, this message translates to:
  /// **'App completamente ridisegnata: note, attività e calendario in un unico posto, sincronizzati sul tuo account.'**
  String get changelog_v2_0_0_bullet_1;

  /// No description provided for @changelog_v2_0_0_bullet_2.
  ///
  /// In it, this message translates to:
  /// **'Note con stili personalizzati, Markdown, liste di controllo, note audio, collegamenti tra note e 6 modelli pronti.'**
  String get changelog_v2_0_0_bullet_2;

  /// No description provided for @changelog_v2_0_0_bullet_3.
  ///
  /// In it, this message translates to:
  /// **'Attività con elenchi, sottoattività, scadenze, ricorrenze e attività speciali.'**
  String get changelog_v2_0_0_bullet_3;

  /// No description provided for @changelog_v2_0_0_bullet_4.
  ///
  /// In it, this message translates to:
  /// **'Nuovo calendario con vista giorno, settimana, mese, anno e programma, compleanni e onomastici, importazione ed esportazione ICS.'**
  String get changelog_v2_0_0_bullet_4;

  /// No description provided for @changelog_v2_0_0_bullet_5.
  ///
  /// In it, this message translates to:
  /// **'Promemoria per note, attività ed eventi, con una schermata dedicata.'**
  String get changelog_v2_0_0_bullet_5;

  /// No description provided for @changelog_v2_0_0_bullet_6.
  ///
  /// In it, this message translates to:
  /// **'Etichette, archivio e cestino con eliminazione automatica dopo 7 giorni.'**
  String get changelog_v2_0_0_bullet_6;

  /// No description provided for @changelog_v2_0_0_bullet_7.
  ///
  /// In it, this message translates to:
  /// **'Statistiche, esportazione delle note in PDF, TXT, JSON, CSV e HTML, backup manuali e automatici.'**
  String get changelog_v2_0_0_bullet_7;

  /// No description provided for @changelog_v2_0_0_bullet_8.
  ///
  /// In it, this message translates to:
  /// **'Widget per la schermata Home di Android.'**
  String get changelog_v2_0_0_bullet_8;

  /// No description provided for @changelog_v2_0_0_bullet_9.
  ///
  /// In it, this message translates to:
  /// **'Pulsante \"Annulla\" dopo aver spostato nel cestino o archiviato note, attività ed eventi.'**
  String get changelog_v2_0_0_bullet_9;

  /// No description provided for @changelog_v2_0_0_bullet_10.
  ///
  /// In it, this message translates to:
  /// **'Eliminare una nota o un\'attività dall\'editor ora la sposta nel cestino invece di cancellarla definitivamente.'**
  String get changelog_v2_0_0_bullet_10;

  /// No description provided for @changelog_v2_0_0_bullet_11.
  ///
  /// In it, this message translates to:
  /// **'Trascina verso il basso su note e attività per aggiornarle, ad esempio dopo un errore di connessione o modifiche fatte da un altro dispositivo.'**
  String get changelog_v2_0_0_bullet_11;

  /// No description provided for @changelog_v2_0_0_bullet_12.
  ///
  /// In it, this message translates to:
  /// **'Pulsante \"Riprova\" quando la sincronizzazione non riesce e \"Crea la prima nota\" quando non ne hai ancora.'**
  String get changelog_v2_0_0_bullet_12;

  /// No description provided for @changelog_v2_0_0_bullet_13.
  ///
  /// In it, this message translates to:
  /// **'Scorri un\'attività verso destra per completarla o verso sinistra per spostarla nel cestino; in vista elenco, scorri una nota verso destra per archiviarla o verso sinistra per cestinarla.'**
  String get changelog_v2_0_0_bullet_13;

  /// No description provided for @changelog_v2_0_0_bullet_14.
  ///
  /// In it, this message translates to:
  /// **'Selettori di data e ora, menu di sistema e date nella lingua dell\'app.'**
  String get changelog_v2_0_0_bullet_14;

  /// No description provided for @changelog_v2_0_0_bullet_15.
  ///
  /// In it, this message translates to:
  /// **'Se l\'avvio non riesce, al posto di una schermata bianca compare un messaggio con il pulsante Riprova.'**
  String get changelog_v2_0_0_bullet_15;

  /// No description provided for @changelog_v2_0_0_bullet_16.
  ///
  /// In it, this message translates to:
  /// **'Guida introduttiva al primo avvio che presenta le funzioni dell\'app, sempre consultabile da Info app.'**
  String get changelog_v2_0_0_bullet_16;

  /// No description provided for @changelog_v2_0_0_bullet_17.
  ///
  /// In it, this message translates to:
  /// **'Ripristino dei backup automatici: in Impostazioni, apri l\'elenco dei backup e tocca quello da ripristinare.'**
  String get changelog_v2_0_0_bullet_17;

  /// No description provided for @changelog_v2_0_0_bullet_18.
  ///
  /// In it, this message translates to:
  /// **'Importare un backup completo ora elimina davvero note, attività ed eventi che non ne fanno parte, invece di farli ricomparire al riavvio.'**
  String get changelog_v2_0_0_bullet_18;

  /// No description provided for @changelog_v2_0_0_bullet_19.
  ///
  /// In it, this message translates to:
  /// **'Calendario ICS: gli eventi ricorrenti esportati mantengono la data di fine, quelli importati non perdono più l\'ultima ripetizione a cavallo del cambio d\'ora, gli orari con fuso esplicito restano corretti e il testo con barre rovesciate viene letto bene.'**
  String get changelog_v2_0_0_bullet_19;

  /// No description provided for @changelog_v2_0_0_bullet_20.
  ///
  /// In it, this message translates to:
  /// **'Durante il primo caricamento di note e attività compare un\'anteprima della lista al posto della rotellina, con un passaggio più morbido tra caricamento, lista e schermata vuota.'**
  String get changelog_v2_0_0_bullet_20;

  /// No description provided for @changelog_v2_0_0_bullet_21.
  ///
  /// In it, this message translates to:
  /// **'Nuova griglia della Home \"a mattoncini\": ogni nota occupa solo lo spazio che le serve, senza vuoti tra le note corte e senza tagliare quelle lunghe.'**
  String get changelog_v2_0_0_bullet_21;

  /// No description provided for @changelog_v2_0_0_bullet_22.
  ///
  /// In it, this message translates to:
  /// **'Toccando la notifica di un promemoria si apre direttamente la nota, l\'attività o l\'evento collegato, anche ad app chiusa.'**
  String get changelog_v2_0_0_bullet_22;

  /// No description provided for @changelog_v2_0_0_bullet_23.
  ///
  /// In it, this message translates to:
  /// **'Animazioni più fluide: la nota si espande dalla sua card quando la apri e il passaggio tra le sezioni del menu avviene in dissolvenza. Con le animazioni ridotte del sistema restano disattivate.'**
  String get changelog_v2_0_0_bullet_23;

  /// No description provided for @changelog_v2_0_0_bullet_24.
  ///
  /// In it, this message translates to:
  /// **'Accessibilità: con TalkBack ogni nota si legge per intero e le azioni rapide (fissa, archivia, cestino, sposta) sono nel menu Azioni; con il testo di sistema molto grande schede e campi non vengono più tagliati, e i pannelli dal basso non finiscono sotto la barra di navigazione.'**
  String get changelog_v2_0_0_bullet_24;

  /// No description provided for @changelog_v2_0_0_bullet_25.
  ///
  /// In it, this message translates to:
  /// **'Modalità offline: le modifiche fatte senza connessione vengono salvate sul dispositivo e inviate appena torni online, con un avviso finché restano in attesa. Anche sul web i dati restano disponibili offline.'**
  String get changelog_v2_0_0_bullet_25;

  /// No description provided for @changelog_v2_0_0_bullet_26.
  ///
  /// In it, this message translates to:
  /// **'Aspetto più uniforme: intestazioni di sezione, voci delle impostazioni, elementi di archivio e cestino ed etichette hanno ora lo stesso stile in tutta l\'app, e le conferme di eliminazione usano sempre il pulsante rosso.'**
  String get changelog_v2_0_0_bullet_26;

  /// No description provided for @changelog_v2_0_0_bullet_27.
  ///
  /// In it, this message translates to:
  /// **'Nuova icona dell\'app: la lampadina con la spunta su sfondo scuro, che si adatta alla forma scelta dal launcher e ai temi colore di Android 13 e successivi.'**
  String get changelog_v2_0_0_bullet_27;

  /// No description provided for @changelog_v2_0_0_bullet_28.
  ///
  /// In it, this message translates to:
  /// **'Il nuovo logo dell\'app compare anche nella schermata di accesso e registrazione, in quella di caricamento e nella pagina Info.'**
  String get changelog_v2_0_0_bullet_28;

  /// No description provided for @changelog_v2_0_0_bullet_29.
  ///
  /// In it, this message translates to:
  /// **'Link nelle note: con il pulsante \"Inserisci link\" aggiungi un collegamento a un sito, e nell\'anteprima Markdown basta toccarlo per aprirlo nel browser. Anche gli indirizzi scritti a mano diventano cliccabili.'**
  String get changelog_v2_0_0_bullet_29;

  /// No description provided for @changelog_v2_0_0_bullet_30.
  ///
  /// In it, this message translates to:
  /// **'Eliminazione dell\'account: in Impostazioni, dopo aver confermato la password o l\'account Google, puoi eliminare definitivamente l\'account insieme a tutte le note, le attività e gli eventi.'**
  String get changelog_v2_0_0_bullet_30;

  /// No description provided for @changelog_v2_0_0_bullet_31.
  ///
  /// In it, this message translates to:
  /// **'Nuova opzione in Impostazioni > Note: scegli se il pulsante + delle note apre il menu con nota, lista, task, audio e modello oppure crea subito una nuova nota. Dal menu, \"Task\" ora apre direttamente un nuovo task.'**
  String get changelog_v2_0_0_bullet_31;

  /// No description provided for @changelog_v2_0_0_bullet_32.
  ///
  /// In it, this message translates to:
  /// **'L\'app è disponibile anche in inglese: segue la lingua del telefono, oppure puoi sceglierla in Impostazioni > Lingua.'**
  String get changelog_v2_0_0_bullet_32;

  /// No description provided for @commonCancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get commonCancel;

  /// No description provided for @commonRetry.
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get commonRetry;

  /// No description provided for @commonEmail.
  ///
  /// In it, this message translates to:
  /// **'Email'**
  String get commonEmail;

  /// No description provided for @commonPassword.
  ///
  /// In it, this message translates to:
  /// **'Password'**
  String get commonPassword;

  /// No description provided for @commonGenericError.
  ///
  /// In it, this message translates to:
  /// **'Si è verificato un errore. Riprova.'**
  String get commonGenericError;

  /// No description provided for @loginTagline.
  ///
  /// In it, this message translates to:
  /// **'Il tuo taccuino digitale'**
  String get loginTagline;

  /// No description provided for @loginTabSignIn.
  ///
  /// In it, this message translates to:
  /// **'Accedi'**
  String get loginTabSignIn;

  /// No description provided for @loginTabRegister.
  ///
  /// In it, this message translates to:
  /// **'Registrati'**
  String get loginTabRegister;

  /// No description provided for @loginOr.
  ///
  /// In it, this message translates to:
  /// **'oppure'**
  String get loginOr;

  /// No description provided for @loginContinueWithGoogle.
  ///
  /// In it, this message translates to:
  /// **'Continua con Google'**
  String get loginContinueWithGoogle;

  /// No description provided for @loginForgotPassword.
  ///
  /// In it, this message translates to:
  /// **'Password dimenticata?'**
  String get loginForgotPassword;

  /// No description provided for @loginSubmitSignIn.
  ///
  /// In it, this message translates to:
  /// **'Accedi'**
  String get loginSubmitSignIn;

  /// No description provided for @loginConfirmPassword.
  ///
  /// In it, this message translates to:
  /// **'Conferma password'**
  String get loginConfirmPassword;

  /// No description provided for @loginSubmitRegister.
  ///
  /// In it, this message translates to:
  /// **'Crea account'**
  String get loginSubmitRegister;

  /// No description provided for @loginShowPassword.
  ///
  /// In it, this message translates to:
  /// **'Mostra password'**
  String get loginShowPassword;

  /// No description provided for @loginHidePassword.
  ///
  /// In it, this message translates to:
  /// **'Nascondi password'**
  String get loginHidePassword;

  /// No description provided for @loginResetEmailSent.
  ///
  /// In it, this message translates to:
  /// **'Email di reimpostazione inviata.'**
  String get loginResetEmailSent;

  /// No description provided for @loginResetTitle.
  ///
  /// In it, this message translates to:
  /// **'Reimposta password'**
  String get loginResetTitle;

  /// No description provided for @loginResetSend.
  ///
  /// In it, this message translates to:
  /// **'Invia'**
  String get loginResetSend;

  /// No description provided for @validationEmailEmpty.
  ///
  /// In it, this message translates to:
  /// **'Inserisci la tua email.'**
  String get validationEmailEmpty;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In it, this message translates to:
  /// **'Formato email non valido.'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordEmpty.
  ///
  /// In it, this message translates to:
  /// **'Inserisci la password.'**
  String get validationPasswordEmpty;

  /// No description provided for @validationPasswordTooShort.
  ///
  /// In it, this message translates to:
  /// **'Minimo 6 caratteri.'**
  String get validationPasswordTooShort;

  /// No description provided for @validationPasswordMismatch.
  ///
  /// In it, this message translates to:
  /// **'Le password non coincidono.'**
  String get validationPasswordMismatch;

  /// No description provided for @authErrorUserNotFound.
  ///
  /// In it, this message translates to:
  /// **'Nessun account trovato con questa email.'**
  String get authErrorUserNotFound;

  /// No description provided for @authErrorWrongPassword.
  ///
  /// In it, this message translates to:
  /// **'Password errata. Riprova.'**
  String get authErrorWrongPassword;

  /// No description provided for @authErrorInvalidCredential.
  ///
  /// In it, this message translates to:
  /// **'Credenziali non valide. Controlla email e password.'**
  String get authErrorInvalidCredential;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In it, this message translates to:
  /// **'Questa email è già associata a un account.'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In it, this message translates to:
  /// **'La password è troppo debole (min. 6 caratteri).'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In it, this message translates to:
  /// **'Troppi tentativi. Riprova più tardi.'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorNetwork.
  ///
  /// In it, this message translates to:
  /// **'Errore di rete. Controlla la connessione.'**
  String get authErrorNetwork;

  /// No description provided for @authErrorUserMismatch.
  ///
  /// In it, this message translates to:
  /// **'L\'account scelto non è quello con cui hai effettuato l\'accesso.'**
  String get authErrorUserMismatch;

  /// No description provided for @authErrorRequiresRecentLogin.
  ///
  /// In it, this message translates to:
  /// **'Per sicurezza, esci e accedi di nuovo prima di riprovare.'**
  String get authErrorRequiresRecentLogin;

  /// No description provided for @onboardingSkip.
  ///
  /// In it, this message translates to:
  /// **'Salta'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In it, this message translates to:
  /// **'Avanti'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In it, this message translates to:
  /// **'Inizia'**
  String get onboardingStart;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In it, this message translates to:
  /// **'Benvenuto in Noteep'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In it, this message translates to:
  /// **'Note, attività e calendario in un unico posto, sincronizzati sul tuo account e disponibili su tutti i tuoi dispositivi.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingNotesTitle.
  ///
  /// In it, this message translates to:
  /// **'Note'**
  String get onboardingNotesTitle;

  /// No description provided for @onboardingNotesBody.
  ///
  /// In it, this message translates to:
  /// **'Scrivi note con stili personalizzati, Markdown, liste di controllo e note audio. Organizzale con etichette e collegale tra loro.'**
  String get onboardingNotesBody;

  /// No description provided for @onboardingTasksTitle.
  ///
  /// In it, this message translates to:
  /// **'Attività'**
  String get onboardingTasksTitle;

  /// No description provided for @onboardingTasksBody.
  ///
  /// In it, this message translates to:
  /// **'Crea elenchi di attività con sottoattività, scadenze e ricorrenze. Scorri un\'attività verso destra per completarla.'**
  String get onboardingTasksBody;

  /// No description provided for @onboardingCalendarTitle.
  ///
  /// In it, this message translates to:
  /// **'Calendario'**
  String get onboardingCalendarTitle;

  /// No description provided for @onboardingCalendarBody.
  ///
  /// In it, this message translates to:
  /// **'Pianifica eventi con vista giorno, settimana, mese, anno e programma. Importa ed esporta i tuoi calendari in formato ICS.'**
  String get onboardingCalendarBody;

  /// No description provided for @onboardingRemindersTitle.
  ///
  /// In it, this message translates to:
  /// **'Promemoria e backup'**
  String get onboardingRemindersTitle;

  /// No description provided for @onboardingRemindersBody.
  ///
  /// In it, this message translates to:
  /// **'Imposta promemoria per note, attività ed eventi. Esporta le note e crea backup manuali o automatici dalle Impostazioni.'**
  String get onboardingRemindersBody;

  /// No description provided for @bootErrorTitle.
  ///
  /// In it, this message translates to:
  /// **'Impossibile avviare Noteep'**
  String get bootErrorTitle;

  /// No description provided for @bootErrorBody.
  ///
  /// In it, this message translates to:
  /// **'Si è verificato un problema durante l\'avvio. Controlla la connessione e riprova.'**
  String get bootErrorBody;

  /// No description provided for @unknownRouteTitle.
  ///
  /// In it, this message translates to:
  /// **'Pagina non trovata'**
  String get unknownRouteTitle;

  /// No description provided for @unknownRouteBody.
  ///
  /// In it, this message translates to:
  /// **'Il contenuto che cercavi non è disponibile.'**
  String get unknownRouteBody;

  /// No description provided for @unknownRouteHome.
  ///
  /// In it, this message translates to:
  /// **'Torna alla home'**
  String get unknownRouteHome;

  /// No description provided for @commonClose.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get commonClose;

  /// No description provided for @commonDelete.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get commonDelete;

  /// No description provided for @commonUndo.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get commonUndo;

  /// No description provided for @commonHide.
  ///
  /// In it, this message translates to:
  /// **'Nascondi'**
  String get commonHide;

  /// No description provided for @commonOk.
  ///
  /// In it, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonPin.
  ///
  /// In it, this message translates to:
  /// **'Fissa'**
  String get commonPin;

  /// No description provided for @commonUnpin.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi pin'**
  String get commonUnpin;

  /// No description provided for @commonArchive.
  ///
  /// In it, this message translates to:
  /// **'Archivia'**
  String get commonArchive;

  /// No description provided for @commonUnarchive.
  ///
  /// In it, this message translates to:
  /// **'Ripristina'**
  String get commonUnarchive;

  /// No description provided for @commonMoveToTrash.
  ///
  /// In it, this message translates to:
  /// **'Sposta nel cestino'**
  String get commonMoveToTrash;

  /// No description provided for @commonTrash.
  ///
  /// In it, this message translates to:
  /// **'Cestino'**
  String get commonTrash;

  /// No description provided for @commonLoading.
  ///
  /// In it, this message translates to:
  /// **'Caricamento…'**
  String get commonLoading;

  /// No description provided for @commonClearSearch.
  ///
  /// In it, this message translates to:
  /// **'Cancella ricerca'**
  String get commonClearSearch;

  /// No description provided for @commonUntitled.
  ///
  /// In it, this message translates to:
  /// **'Senza titolo'**
  String get commonUntitled;

  /// No description provided for @commonBold.
  ///
  /// In it, this message translates to:
  /// **'Grassetto'**
  String get commonBold;

  /// No description provided for @commonItalic.
  ///
  /// In it, this message translates to:
  /// **'Corsivo'**
  String get commonItalic;

  /// No description provided for @commonFont.
  ///
  /// In it, this message translates to:
  /// **'Font'**
  String get commonFont;

  /// No description provided for @commonMoveEarlier.
  ///
  /// In it, this message translates to:
  /// **'Sposta prima'**
  String get commonMoveEarlier;

  /// No description provided for @commonMoveLater.
  ///
  /// In it, this message translates to:
  /// **'Sposta dopo'**
  String get commonMoveLater;

  /// No description provided for @commonRemoveReminder.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi promemoria'**
  String get commonRemoveReminder;

  /// No description provided for @commonSyncError.
  ///
  /// In it, this message translates to:
  /// **'Errore di sincronizzazione. Verifica la connessione e riprova.'**
  String get commonSyncError;

  /// No description provided for @commonLinkOpenFailed.
  ///
  /// In it, this message translates to:
  /// **'Impossibile aprire il link'**
  String get commonLinkOpenFailed;

  /// No description provided for @appLogoLabel.
  ///
  /// In it, this message translates to:
  /// **'Logo Noteep'**
  String get appLogoLabel;

  /// No description provided for @navNotes.
  ///
  /// In it, this message translates to:
  /// **'Note'**
  String get navNotes;

  /// No description provided for @navTasks.
  ///
  /// In it, this message translates to:
  /// **'Task'**
  String get navTasks;

  /// No description provided for @navReminders.
  ///
  /// In it, this message translates to:
  /// **'Promemoria'**
  String get navReminders;

  /// No description provided for @navCalendar.
  ///
  /// In it, this message translates to:
  /// **'Calendario'**
  String get navCalendar;

  /// No description provided for @navLabels.
  ///
  /// In it, this message translates to:
  /// **'Etichette'**
  String get navLabels;

  /// No description provided for @navArchive.
  ///
  /// In it, this message translates to:
  /// **'Archivio'**
  String get navArchive;

  /// No description provided for @navTrash.
  ///
  /// In it, this message translates to:
  /// **'Cestino'**
  String get navTrash;

  /// No description provided for @navSettings.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get navSettings;

  /// No description provided for @navSignOut.
  ///
  /// In it, this message translates to:
  /// **'Esci'**
  String get navSignOut;

  /// No description provided for @navExpandMenu.
  ///
  /// In it, this message translates to:
  /// **'Espandi menu'**
  String get navExpandMenu;

  /// No description provided for @navCollapseMenu.
  ///
  /// In it, this message translates to:
  /// **'Comprimi menu'**
  String get navCollapseMenu;

  /// No description provided for @navOpenMenu.
  ///
  /// In it, this message translates to:
  /// **'Apri menu'**
  String get navOpenMenu;

  /// No description provided for @syncChangeRejected.
  ///
  /// In it, this message translates to:
  /// **'Una modifica non è stata sincronizzata ed è stata annullata.'**
  String get syncChangeRejected;

  /// No description provided for @syncPendingBanner.
  ///
  /// In it, this message translates to:
  /// **'Modifiche non ancora sincronizzate: verranno inviate appena torni online.'**
  String get syncPendingBanner;

  /// No description provided for @sortTitle.
  ///
  /// In it, this message translates to:
  /// **'Ordina per'**
  String get sortTitle;

  /// No description provided for @sortCreatedDate.
  ///
  /// In it, this message translates to:
  /// **'Data di creazione'**
  String get sortCreatedDate;

  /// No description provided for @sortModifiedDate.
  ///
  /// In it, this message translates to:
  /// **'Data di modifica'**
  String get sortModifiedDate;

  /// No description provided for @sortNewestFirst.
  ///
  /// In it, this message translates to:
  /// **'Più recenti prima'**
  String get sortNewestFirst;

  /// No description provided for @sortOldestFirst.
  ///
  /// In it, this message translates to:
  /// **'Più vecchie prima'**
  String get sortOldestFirst;

  /// No description provided for @homeSearchHint.
  ///
  /// In it, this message translates to:
  /// **'Cerca nelle note...'**
  String get homeSearchHint;

  /// No description provided for @homeSortTooltip.
  ///
  /// In it, this message translates to:
  /// **'Ordina note'**
  String get homeSortTooltip;

  /// No description provided for @homeNewNote.
  ///
  /// In it, this message translates to:
  /// **'Nuova nota'**
  String get homeNewNote;

  /// No description provided for @homeNoResults.
  ///
  /// In it, this message translates to:
  /// **'Nessuna nota trovata'**
  String get homeNoResults;

  /// No description provided for @homeEmpty.
  ///
  /// In it, this message translates to:
  /// **'Ancora nessuna nota'**
  String get homeEmpty;

  /// No description provided for @homeCreateFirst.
  ///
  /// In it, this message translates to:
  /// **'Crea la prima nota'**
  String get homeCreateFirst;

  /// No description provided for @homeFabTask.
  ///
  /// In it, this message translates to:
  /// **'Task'**
  String get homeFabTask;

  /// No description provided for @homeFabChecklist.
  ///
  /// In it, this message translates to:
  /// **'Lista'**
  String get homeFabChecklist;

  /// No description provided for @homeFabNote.
  ///
  /// In it, this message translates to:
  /// **'Nota'**
  String get homeFabNote;

  /// No description provided for @homeFabAudio.
  ///
  /// In it, this message translates to:
  /// **'Audio'**
  String get homeFabAudio;

  /// No description provided for @homeFabTemplate.
  ///
  /// In it, this message translates to:
  /// **'Modello'**
  String get homeFabTemplate;

  /// No description provided for @homeFabCloseMenu.
  ///
  /// In it, this message translates to:
  /// **'Chiudi menu azioni rapide'**
  String get homeFabCloseMenu;

  /// No description provided for @homeFabOpenMenu.
  ///
  /// In it, this message translates to:
  /// **'Nuova azione rapida'**
  String get homeFabOpenMenu;

  /// No description provided for @homeFabCloseTooltip.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get homeFabCloseTooltip;

  /// No description provided for @homeFabOpenTooltip.
  ///
  /// In it, this message translates to:
  /// **'Nuovo'**
  String get homeFabOpenTooltip;

  /// No description provided for @noteArchived.
  ///
  /// In it, this message translates to:
  /// **'Nota archiviata'**
  String get noteArchived;

  /// No description provided for @noteUnarchived.
  ///
  /// In it, this message translates to:
  /// **'Nota rimossa dall\'archivio'**
  String get noteUnarchived;

  /// No description provided for @noteTrashed.
  ///
  /// In it, this message translates to:
  /// **'Nota spostata nel cestino'**
  String get noteTrashed;

  /// No description provided for @noteOpenHint.
  ///
  /// In it, this message translates to:
  /// **'Apri nota'**
  String get noteOpenHint;

  /// No description provided for @noteReminderSetLabel.
  ///
  /// In it, this message translates to:
  /// **'Promemoria impostato'**
  String get noteReminderSetLabel;

  /// No description provided for @notePinnedLabel.
  ///
  /// In it, this message translates to:
  /// **'Nota fissata'**
  String get notePinnedLabel;

  /// No description provided for @noteChecklistMore.
  ///
  /// In it, this message translates to:
  /// **'+{count} altri'**
  String noteChecklistMore(int count);

  /// No description provided for @editorUndo.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get editorUndo;

  /// No description provided for @editorRedo.
  ///
  /// In it, this message translates to:
  /// **'Ripeti'**
  String get editorRedo;

  /// No description provided for @editorInsertLink.
  ///
  /// In it, this message translates to:
  /// **'Inserisci link'**
  String get editorInsertLink;

  /// No description provided for @editorEdit.
  ///
  /// In it, this message translates to:
  /// **'Modifica'**
  String get editorEdit;

  /// No description provided for @editorMarkdownPreview.
  ///
  /// In it, this message translates to:
  /// **'Anteprima Markdown'**
  String get editorMarkdownPreview;

  /// No description provided for @editorShare.
  ///
  /// In it, this message translates to:
  /// **'Condividi'**
  String get editorShare;

  /// No description provided for @editorBackgroundColor.
  ///
  /// In it, this message translates to:
  /// **'Colore sfondo'**
  String get editorBackgroundColor;

  /// No description provided for @editorEditStyle.
  ///
  /// In it, this message translates to:
  /// **'Modifica stile'**
  String get editorEditStyle;

  /// No description provided for @editorReminder.
  ///
  /// In it, this message translates to:
  /// **'Promemoria'**
  String get editorReminder;

  /// No description provided for @editorLinkNote.
  ///
  /// In it, this message translates to:
  /// **'Collega nota'**
  String get editorLinkNote;

  /// No description provided for @editorRecordAudio.
  ///
  /// In it, this message translates to:
  /// **'Registra audio'**
  String get editorRecordAudio;

  /// No description provided for @editorAddItem.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi elemento'**
  String get editorAddItem;

  /// No description provided for @editorDeleteNote.
  ///
  /// In it, this message translates to:
  /// **'Elimina nota'**
  String get editorDeleteNote;

  /// No description provided for @editorDeleteConfirm.
  ///
  /// In it, this message translates to:
  /// **'Vuoi spostare questa nota nel cestino?'**
  String get editorDeleteConfirm;

  /// No description provided for @editorTitleHint.
  ///
  /// In it, this message translates to:
  /// **'Titolo'**
  String get editorTitleHint;

  /// No description provided for @editorContentHint.
  ///
  /// In it, this message translates to:
  /// **'Nota'**
  String get editorContentHint;

  /// No description provided for @editorItemHint.
  ///
  /// In it, this message translates to:
  /// **'Elemento...'**
  String get editorItemHint;

  /// No description provided for @editorLastModified.
  ///
  /// In it, this message translates to:
  /// **'Ultima modifica: {date}'**
  String editorLastModified(String date);

  /// No description provided for @editorChooseBackground.
  ///
  /// In it, this message translates to:
  /// **'Scegli colore sfondo'**
  String get editorChooseBackground;

  /// No description provided for @editorReminderScheduled.
  ///
  /// In it, this message translates to:
  /// **'Promemoria: {date}'**
  String editorReminderScheduled(String date);

  /// No description provided for @editorReminderFailed.
  ///
  /// In it, this message translates to:
  /// **'Impossibile pianificare il promemoria.'**
  String get editorReminderFailed;

  /// No description provided for @editorReminderRemoved.
  ///
  /// In it, this message translates to:
  /// **'Promemoria rimosso'**
  String get editorReminderRemoved;

  /// No description provided for @editorReminderNotificationTitle.
  ///
  /// In it, this message translates to:
  /// **'Promemoria nota'**
  String get editorReminderNotificationTitle;

  /// No description provided for @editorReminderNotificationBody.
  ///
  /// In it, this message translates to:
  /// **'Hai un promemoria per questa nota'**
  String get editorReminderNotificationBody;

  /// No description provided for @editorAudioSection.
  ///
  /// In it, this message translates to:
  /// **'Audio'**
  String get editorAudioSection;

  /// No description provided for @editorLinkedNotes.
  ///
  /// In it, this message translates to:
  /// **'Note collegate'**
  String get editorLinkedNotes;

  /// No description provided for @editorRecordingError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile registrare l\'audio. Controlla il permesso del microfono.'**
  String get editorRecordingError;

  /// No description provided for @editorStopAndAttach.
  ///
  /// In it, this message translates to:
  /// **'Ferma e allega'**
  String get editorStopAndAttach;

  /// No description provided for @editorLinkText.
  ///
  /// In it, this message translates to:
  /// **'Testo (facoltativo)'**
  String get editorLinkText;

  /// No description provided for @editorLinkAddress.
  ///
  /// In it, this message translates to:
  /// **'Indirizzo'**
  String get editorLinkAddress;

  /// No description provided for @editorLinkInvalid.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un indirizzo valido'**
  String get editorLinkInvalid;

  /// No description provided for @editorLinkInsert.
  ///
  /// In it, this message translates to:
  /// **'Inserisci'**
  String get editorLinkInsert;

  /// No description provided for @editorSearchNoteHint.
  ///
  /// In it, this message translates to:
  /// **'Cerca nota...'**
  String get editorSearchNoteHint;

  /// No description provided for @editorUntitledNote.
  ///
  /// In it, this message translates to:
  /// **'Nota senza titolo'**
  String get editorUntitledNote;

  /// No description provided for @styleTitle.
  ///
  /// In it, this message translates to:
  /// **'Stile testo'**
  String get styleTitle;

  /// No description provided for @styleSectionTitle.
  ///
  /// In it, this message translates to:
  /// **'Titolo'**
  String get styleSectionTitle;

  /// No description provided for @styleSectionBody.
  ///
  /// In it, this message translates to:
  /// **'Corpo'**
  String get styleSectionBody;

  /// No description provided for @styleSize.
  ///
  /// In it, this message translates to:
  /// **'Dimensione: {size}pt'**
  String styleSize(String size);

  /// No description provided for @styleStrikethrough.
  ///
  /// In it, this message translates to:
  /// **'Sbarrato'**
  String get styleStrikethrough;

  /// No description provided for @styleTextColor.
  ///
  /// In it, this message translates to:
  /// **'Colore testo'**
  String get styleTextColor;

  /// No description provided for @styleTitleColor.
  ///
  /// In it, this message translates to:
  /// **'Colore titolo'**
  String get styleTitleColor;

  /// No description provided for @styleResetTitle.
  ///
  /// In it, this message translates to:
  /// **'Ripristina stile titolo'**
  String get styleResetTitle;

  /// No description provided for @styleMaterialColors.
  ///
  /// In it, this message translates to:
  /// **'Colori Material'**
  String get styleMaterialColors;

  /// No description provided for @templateChoose.
  ///
  /// In it, this message translates to:
  /// **'Scegli un modello'**
  String get templateChoose;

  /// No description provided for @templateSectionNotes.
  ///
  /// In it, this message translates to:
  /// **'Note'**
  String get templateSectionNotes;

  /// No description provided for @templateSectionChecklists.
  ///
  /// In it, this message translates to:
  /// **'Checklist'**
  String get templateSectionChecklists;

  /// No description provided for @templateMeetingName.
  ///
  /// In it, this message translates to:
  /// **'Note riunione'**
  String get templateMeetingName;

  /// No description provided for @templateMeetingDescription.
  ///
  /// In it, this message translates to:
  /// **'Struttura per prendere appunti durante una riunione'**
  String get templateMeetingDescription;

  /// No description provided for @templateMeetingContent.
  ///
  /// In it, this message translates to:
  /// **'## Riunione del [DATA]\n\n**Partecipanti:**\n- \n\n**Ordine del giorno:**\n1. \n\n**Punti discussi:**\n\n**Decisioni prese:**\n\n**Azioni da fare:**\n- \n\n**Prossima riunione:** '**
  String get templateMeetingContent;

  /// No description provided for @templateJournalName.
  ///
  /// In it, this message translates to:
  /// **'Diario giornaliero'**
  String get templateJournalName;

  /// No description provided for @templateJournalDescription.
  ///
  /// In it, this message translates to:
  /// **'Traccia i tuoi pensieri e obiettivi del giorno'**
  String get templateJournalDescription;

  /// No description provided for @templateJournalContent.
  ///
  /// In it, this message translates to:
  /// **'## [DATA]\n\n**Come mi sento oggi:**\n\n**Tre cose per cui sono grato:**\n1. \n2. \n3. \n\n**Obiettivi di oggi:**\n\n**Riflessioni della giornata:**\n'**
  String get templateJournalContent;

  /// No description provided for @templateProjectName.
  ///
  /// In it, this message translates to:
  /// **'Piano di progetto'**
  String get templateProjectName;

  /// No description provided for @templateProjectDescription.
  ///
  /// In it, this message translates to:
  /// **'Organizza obiettivi, milestones e risorse di un progetto'**
  String get templateProjectDescription;

  /// No description provided for @templateProjectContent.
  ///
  /// In it, this message translates to:
  /// **'## Progetto: [NOME]\n\n**Obiettivo:**\n\n**Scadenza:**\n\n**Milestones:**\n- [ ] \n- [ ] \n\n**Risorse necessarie:**\n\n**Note:**\n'**
  String get templateProjectContent;

  /// No description provided for @templateShoppingName.
  ///
  /// In it, this message translates to:
  /// **'Lista spesa'**
  String get templateShoppingName;

  /// No description provided for @templateShoppingDescription.
  ///
  /// In it, this message translates to:
  /// **'Lista della spesa con caselle di controllo'**
  String get templateShoppingDescription;

  /// No description provided for @templateShoppingItems.
  ///
  /// In it, this message translates to:
  /// **'Frutta e verdura\nLatte\nPane\nUova'**
  String get templateShoppingItems;

  /// No description provided for @templateTravelName.
  ///
  /// In it, this message translates to:
  /// **'Lista viaggio'**
  String get templateTravelName;

  /// No description provided for @templateTravelDescription.
  ///
  /// In it, this message translates to:
  /// **'Non dimenticare nulla per il tuo viaggio'**
  String get templateTravelDescription;

  /// No description provided for @templateTravelItems.
  ///
  /// In it, this message translates to:
  /// **'Passaporto / Documenti\nCaricabatterie\nVestiti\nProdotti da toilette\nMedicinali\nContanti / Carte'**
  String get templateTravelItems;

  /// No description provided for @templateIdeasName.
  ///
  /// In it, this message translates to:
  /// **'Brainstorming idee'**
  String get templateIdeasName;

  /// No description provided for @templateIdeasDescription.
  ///
  /// In it, this message translates to:
  /// **'Spazio libero per raccogliere idee'**
  String get templateIdeasDescription;

  /// No description provided for @templateIdeasContent.
  ///
  /// In it, this message translates to:
  /// **'## Idea: [TITOLO]\n\n**Descrizione:**\n\n**Pro:**\n- \n\n**Contro:**\n- \n\n**Prossimi passi:**\n'**
  String get templateIdeasContent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
