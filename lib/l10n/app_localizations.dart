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
  /// **'Sistema'**
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

  /// No description provided for @editorChooseBackground.
  ///
  /// In it, this message translates to:
  /// **'Scegli colore sfondo'**
  String get editorChooseBackground;

  /// No description provided for @editorReminderFailed.
  ///
  /// In it, this message translates to:
  /// **'Impossibile pianificare il promemoria.'**
  String get editorReminderFailed;

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

  /// No description provided for @commonEdit.
  ///
  /// In it, this message translates to:
  /// **'Modifica'**
  String get commonEdit;

  /// No description provided for @commonShare.
  ///
  /// In it, this message translates to:
  /// **'Condividi'**
  String get commonShare;

  /// No description provided for @commonReminderScheduled.
  ///
  /// In it, this message translates to:
  /// **'Promemoria: {date}'**
  String commonReminderScheduled(String date);

  /// No description provided for @commonReminderRemoved.
  ///
  /// In it, this message translates to:
  /// **'Promemoria rimosso'**
  String get commonReminderRemoved;

  /// No description provided for @commonLastModified.
  ///
  /// In it, this message translates to:
  /// **'Ultima modifica: {date}'**
  String commonLastModified(String date);

  /// No description provided for @tasksSearchHint.
  ///
  /// In it, this message translates to:
  /// **'Cerca tra i task...'**
  String get tasksSearchHint;

  /// No description provided for @tasksSortTooltip.
  ///
  /// In it, this message translates to:
  /// **'Ordina task'**
  String get tasksSortTooltip;

  /// No description provided for @tasksNewTask.
  ///
  /// In it, this message translates to:
  /// **'Nuovo task'**
  String get tasksNewTask;

  /// No description provided for @tasksNewTaskHint.
  ///
  /// In it, this message translates to:
  /// **'Cosa devi fare?'**
  String get tasksNewTaskHint;

  /// No description provided for @tasksAdd.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get tasksAdd;

  /// No description provided for @tasksNewList.
  ///
  /// In it, this message translates to:
  /// **'Nuovo elenco'**
  String get tasksNewList;

  /// No description provided for @tasksListNameHint.
  ///
  /// In it, this message translates to:
  /// **'Nome elenco'**
  String get tasksListNameHint;

  /// No description provided for @tasksCreate.
  ///
  /// In it, this message translates to:
  /// **'Crea'**
  String get tasksCreate;

  /// No description provided for @tasksDeleteList.
  ///
  /// In it, this message translates to:
  /// **'Elimina elenco'**
  String get tasksDeleteList;

  /// No description provided for @tasksDeleteListConfirm.
  ///
  /// In it, this message translates to:
  /// **'Vuoi davvero eliminare l\'elenco \"{name}\"?'**
  String tasksDeleteListConfirm(String name);

  /// No description provided for @tasksTabAll.
  ///
  /// In it, this message translates to:
  /// **'Tutte'**
  String get tasksTabAll;

  /// No description provided for @tasksTabStarred.
  ///
  /// In it, this message translates to:
  /// **'Speciali'**
  String get tasksTabStarred;

  /// No description provided for @tasksEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessun task trovato'**
  String get tasksEmpty;

  /// No description provided for @tasksCompletedSection.
  ///
  /// In it, this message translates to:
  /// **'Completati'**
  String get tasksCompletedSection;

  /// No description provided for @tasksComplete.
  ///
  /// In it, this message translates to:
  /// **'Completa'**
  String get tasksComplete;

  /// No description provided for @tasksReopen.
  ///
  /// In it, this message translates to:
  /// **'Riapri'**
  String get tasksReopen;

  /// No description provided for @tasksCompleted.
  ///
  /// In it, this message translates to:
  /// **'Task completato'**
  String get tasksCompleted;

  /// No description provided for @tasksReopened.
  ///
  /// In it, this message translates to:
  /// **'Task riaperto'**
  String get tasksReopened;

  /// No description provided for @tasksTrashed.
  ///
  /// In it, this message translates to:
  /// **'Task spostato nel cestino'**
  String get tasksTrashed;

  /// No description provided for @tasksAddStar.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi agli speciali'**
  String get tasksAddStar;

  /// No description provided for @tasksRemoveStar.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi dagli speciali'**
  String get tasksRemoveStar;

  /// No description provided for @tasksMoveToList.
  ///
  /// In it, this message translates to:
  /// **'Sposta in elenco'**
  String get tasksMoveToList;

  /// No description provided for @tasksDeleteTask.
  ///
  /// In it, this message translates to:
  /// **'Elimina task'**
  String get tasksDeleteTask;

  /// No description provided for @tasksDeleteTaskNamedConfirm.
  ///
  /// In it, this message translates to:
  /// **'Vuoi spostare \"{title}\" nel cestino?'**
  String tasksDeleteTaskNamedConfirm(String title);

  /// No description provided for @tasksDeleteTaskConfirm.
  ///
  /// In it, this message translates to:
  /// **'Vuoi spostare questo task nel cestino?'**
  String get tasksDeleteTaskConfirm;

  /// No description provided for @tasksMoveToListTitle.
  ///
  /// In it, this message translates to:
  /// **'Sposta in un elenco'**
  String get tasksMoveToListTitle;

  /// No description provided for @tasksNoList.
  ///
  /// In it, this message translates to:
  /// **'Nessun elenco'**
  String get tasksNoList;

  /// No description provided for @tasksUnknownList.
  ///
  /// In it, this message translates to:
  /// **'Sconosciuto'**
  String get tasksUnknownList;

  /// No description provided for @taskEditorTitle.
  ///
  /// In it, this message translates to:
  /// **'Task'**
  String get taskEditorTitle;

  /// No description provided for @taskEditorUndo.
  ///
  /// In it, this message translates to:
  /// **'Annulla (Ctrl+Z)'**
  String get taskEditorUndo;

  /// No description provided for @taskEditorRedo.
  ///
  /// In it, this message translates to:
  /// **'Ripeti (Ctrl+Y)'**
  String get taskEditorRedo;

  /// No description provided for @taskEditorUnpin.
  ///
  /// In it, this message translates to:
  /// **'Sposta in alto'**
  String get taskEditorUnpin;

  /// No description provided for @taskEditorPin.
  ///
  /// In it, this message translates to:
  /// **'Fissa in alto'**
  String get taskEditorPin;

  /// No description provided for @taskEditorDueDate.
  ///
  /// In it, this message translates to:
  /// **'Imposta data scadenza'**
  String get taskEditorDueDate;

  /// No description provided for @taskEditorReminder.
  ///
  /// In it, this message translates to:
  /// **'Promemoria'**
  String get taskEditorReminder;

  /// No description provided for @taskEditorRecurrence.
  ///
  /// In it, this message translates to:
  /// **'Imposta ripetizione'**
  String get taskEditorRecurrence;

  /// No description provided for @taskEditorRecurrenceTitle.
  ///
  /// In it, this message translates to:
  /// **'Ripetizione'**
  String get taskEditorRecurrenceTitle;

  /// No description provided for @taskEditorTitleHint.
  ///
  /// In it, this message translates to:
  /// **'Titolo task'**
  String get taskEditorTitleHint;

  /// No description provided for @taskEditorDescriptionHint.
  ///
  /// In it, this message translates to:
  /// **'Descrizione...'**
  String get taskEditorDescriptionHint;

  /// No description provided for @taskEditorSubtasks.
  ///
  /// In it, this message translates to:
  /// **'Sottoattività ({completed}/{total})'**
  String taskEditorSubtasks(int completed, int total);

  /// No description provided for @taskEditorAddSubtaskHint.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi sottoattività...'**
  String get taskEditorAddSubtaskHint;

  /// No description provided for @taskEditorReminderNotificationTitle.
  ///
  /// In it, this message translates to:
  /// **'Promemoria task'**
  String get taskEditorReminderNotificationTitle;

  /// No description provided for @taskEditorReminderNotificationBody.
  ///
  /// In it, this message translates to:
  /// **'Hai un promemoria per questo task'**
  String get taskEditorReminderNotificationBody;

  /// No description provided for @recurrenceNone.
  ///
  /// In it, this message translates to:
  /// **'Nessuna'**
  String get recurrenceNone;

  /// No description provided for @recurrenceDaily.
  ///
  /// In it, this message translates to:
  /// **'Giornaliero'**
  String get recurrenceDaily;

  /// No description provided for @recurrenceWeekly.
  ///
  /// In it, this message translates to:
  /// **'Settimanale'**
  String get recurrenceWeekly;

  /// No description provided for @recurrenceMonthly.
  ///
  /// In it, this message translates to:
  /// **'Mensile'**
  String get recurrenceMonthly;

  /// No description provided for @recurrenceYearly.
  ///
  /// In it, this message translates to:
  /// **'Annuale'**
  String get recurrenceYearly;

  /// No description provided for @commonSave.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get commonSave;

  /// No description provided for @commonRestore.
  ///
  /// In it, this message translates to:
  /// **'Ripristina'**
  String get commonRestore;

  /// No description provided for @commonUntitledParens.
  ///
  /// In it, this message translates to:
  /// **'(senza titolo)'**
  String get commonUntitledParens;

  /// No description provided for @commonTabNotes.
  ///
  /// In it, this message translates to:
  /// **'Note'**
  String get commonTabNotes;

  /// No description provided for @commonTabTasks.
  ///
  /// In it, this message translates to:
  /// **'Task'**
  String get commonTabTasks;

  /// No description provided for @commonTabEvents.
  ///
  /// In it, this message translates to:
  /// **'Eventi'**
  String get commonTabEvents;

  /// No description provided for @commonToday.
  ///
  /// In it, this message translates to:
  /// **'Oggi'**
  String get commonToday;

  /// No description provided for @calendarSearchHint.
  ///
  /// In it, this message translates to:
  /// **'Cerca eventi...'**
  String get calendarSearchHint;

  /// No description provided for @calendarChangeView.
  ///
  /// In it, this message translates to:
  /// **'Cambia visualizzazione'**
  String get calendarChangeView;

  /// No description provided for @calendarViewDay.
  ///
  /// In it, this message translates to:
  /// **'Giorno'**
  String get calendarViewDay;

  /// No description provided for @calendarViewWeek.
  ///
  /// In it, this message translates to:
  /// **'Settimana'**
  String get calendarViewWeek;

  /// No description provided for @calendarViewMonth.
  ///
  /// In it, this message translates to:
  /// **'Mese'**
  String get calendarViewMonth;

  /// No description provided for @calendarViewYear.
  ///
  /// In it, this message translates to:
  /// **'Anno'**
  String get calendarViewYear;

  /// No description provided for @calendarViewSchedule.
  ///
  /// In it, this message translates to:
  /// **'Programma'**
  String get calendarViewSchedule;

  /// No description provided for @calendarViewSevenDays.
  ///
  /// In it, this message translates to:
  /// **'7 giorni'**
  String get calendarViewSevenDays;

  /// No description provided for @calendarPreviousDay.
  ///
  /// In it, this message translates to:
  /// **'Giorno precedente'**
  String get calendarPreviousDay;

  /// No description provided for @calendarNextDay.
  ///
  /// In it, this message translates to:
  /// **'Giorno successivo'**
  String get calendarNextDay;

  /// No description provided for @calendarPreviousMonth.
  ///
  /// In it, this message translates to:
  /// **'Mese precedente'**
  String get calendarPreviousMonth;

  /// No description provided for @calendarNextMonth.
  ///
  /// In it, this message translates to:
  /// **'Mese successivo'**
  String get calendarNextMonth;

  /// No description provided for @calendarPreviousYear.
  ///
  /// In it, this message translates to:
  /// **'Anno precedente'**
  String get calendarPreviousYear;

  /// No description provided for @calendarNextYear.
  ///
  /// In it, this message translates to:
  /// **'Anno successivo'**
  String get calendarNextYear;

  /// No description provided for @calendarNoEventsDay.
  ///
  /// In it, this message translates to:
  /// **'Nessun evento per questo giorno'**
  String get calendarNoEventsDay;

  /// No description provided for @calendarNoEventsScheduled.
  ///
  /// In it, this message translates to:
  /// **'Nessun evento in programma'**
  String get calendarNoEventsScheduled;

  /// No description provided for @calendarNoEventsFound.
  ///
  /// In it, this message translates to:
  /// **'Nessun evento trovato'**
  String get calendarNoEventsFound;

  /// No description provided for @calendarAdd.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get calendarAdd;

  /// No description provided for @calendarAllDay.
  ///
  /// In it, this message translates to:
  /// **'Tutto il giorno'**
  String get calendarAllDay;

  /// No description provided for @calendarEndTime.
  ///
  /// In it, this message translates to:
  /// **'Ora di fine'**
  String get calendarEndTime;

  /// No description provided for @calendarNoEndTime.
  ///
  /// In it, this message translates to:
  /// **'Nessuna'**
  String get calendarNoEndTime;

  /// No description provided for @calendarRemoveEndTime.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi ora di fine'**
  String get calendarRemoveEndTime;

  /// No description provided for @calendarBirthday.
  ///
  /// In it, this message translates to:
  /// **'Compleanno'**
  String get calendarBirthday;

  /// No description provided for @calendarNameDay.
  ///
  /// In it, this message translates to:
  /// **'Onomastico'**
  String get calendarNameDay;

  /// No description provided for @calendarRecurrence.
  ///
  /// In it, this message translates to:
  /// **'Ricorrenza'**
  String get calendarRecurrence;

  /// No description provided for @calendarEventTitle.
  ///
  /// In it, this message translates to:
  /// **'Evento'**
  String get calendarEventTitle;

  /// No description provided for @calendarDeleteEvent.
  ///
  /// In it, this message translates to:
  /// **'Elimina evento'**
  String get calendarDeleteEvent;

  /// No description provided for @calendarDeleteEventConfirm.
  ///
  /// In it, this message translates to:
  /// **'Vuoi spostare questo evento nel cestino?'**
  String get calendarDeleteEventConfirm;

  /// No description provided for @calendarEventTrashed.
  ///
  /// In it, this message translates to:
  /// **'Evento spostato nel cestino'**
  String get calendarEventTrashed;

  /// No description provided for @calendarReminder.
  ///
  /// In it, this message translates to:
  /// **'Promemoria'**
  String get calendarReminder;

  /// No description provided for @calendarTitleHint.
  ///
  /// In it, this message translates to:
  /// **'Titolo'**
  String get calendarTitleHint;

  /// No description provided for @calendarDescriptionHint.
  ///
  /// In it, this message translates to:
  /// **'Descrizione'**
  String get calendarDescriptionHint;

  /// No description provided for @calendarReminderNotificationTitle.
  ///
  /// In it, this message translates to:
  /// **'Promemoria evento'**
  String get calendarReminderNotificationTitle;

  /// No description provided for @calendarReminderNotificationBody.
  ///
  /// In it, this message translates to:
  /// **'Hai un promemoria per questo evento'**
  String get calendarReminderNotificationBody;

  /// No description provided for @eventRecurrenceNone.
  ///
  /// In it, this message translates to:
  /// **'Non ripetere'**
  String get eventRecurrenceNone;

  /// No description provided for @eventRecurrenceDaily.
  ///
  /// In it, this message translates to:
  /// **'Giornalmente'**
  String get eventRecurrenceDaily;

  /// No description provided for @eventRecurrenceWeekly.
  ///
  /// In it, this message translates to:
  /// **'Settimanalmente'**
  String get eventRecurrenceWeekly;

  /// No description provided for @eventRecurrenceMonthly.
  ///
  /// In it, this message translates to:
  /// **'Mensilmente'**
  String get eventRecurrenceMonthly;

  /// No description provided for @eventRecurrenceYearly.
  ///
  /// In it, this message translates to:
  /// **'Annualmente'**
  String get eventRecurrenceYearly;

  /// No description provided for @remindersUpcoming.
  ///
  /// In it, this message translates to:
  /// **'In arrivo'**
  String get remindersUpcoming;

  /// No description provided for @remindersPast.
  ///
  /// In it, this message translates to:
  /// **'Scaduti'**
  String get remindersPast;

  /// No description provided for @remindersEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessun promemoria'**
  String get remindersEmpty;

  /// No description provided for @remindersEmptyHint.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi un promemoria aprendo\nuna nota o un task.'**
  String get remindersEmptyHint;

  /// No description provided for @remindersUntitledNote.
  ///
  /// In it, this message translates to:
  /// **'Nota senza titolo'**
  String get remindersUntitledNote;

  /// No description provided for @remindersUntitledTask.
  ///
  /// In it, this message translates to:
  /// **'Task senza titolo'**
  String get remindersUntitledTask;

  /// No description provided for @remindersClearPast.
  ///
  /// In it, this message translates to:
  /// **'Cancella scaduti'**
  String get remindersClearPast;

  /// No description provided for @remindersPastCleared.
  ///
  /// In it, this message translates to:
  /// **'Promemoria scaduti rimossi'**
  String get remindersPastCleared;

  /// No description provided for @archiveEmptyNotes.
  ///
  /// In it, this message translates to:
  /// **'Nessuna nota archiviata'**
  String get archiveEmptyNotes;

  /// No description provided for @archiveEmptyTasks.
  ///
  /// In it, this message translates to:
  /// **'Nessun task archiviato'**
  String get archiveEmptyTasks;

  /// No description provided for @archiveEmptyEvents.
  ///
  /// In it, this message translates to:
  /// **'Nessun evento archiviato'**
  String get archiveEmptyEvents;

  /// No description provided for @trashEmptyAction.
  ///
  /// In it, this message translates to:
  /// **'Svuota'**
  String get trashEmptyAction;

  /// No description provided for @trashAutoDeleteInfo.
  ///
  /// In it, this message translates to:
  /// **'Gli elementi vengono eliminati definitivamente dopo 7 giorni.'**
  String get trashAutoDeleteInfo;

  /// No description provided for @trashEmptyTitle.
  ///
  /// In it, this message translates to:
  /// **'Svuota cestino'**
  String get trashEmptyTitle;

  /// No description provided for @trashEmptyConfirm.
  ///
  /// In it, this message translates to:
  /// **'Tutti gli elementi nel cestino verranno eliminati definitivamente.'**
  String get trashEmptyConfirm;

  /// No description provided for @trashEmptyNotes.
  ///
  /// In it, this message translates to:
  /// **'Nessuna nota nel cestino'**
  String get trashEmptyNotes;

  /// No description provided for @trashEmptyTasks.
  ///
  /// In it, this message translates to:
  /// **'Nessun task nel cestino'**
  String get trashEmptyTasks;

  /// No description provided for @trashEmptyEvents.
  ///
  /// In it, this message translates to:
  /// **'Nessun evento nel cestino'**
  String get trashEmptyEvents;

  /// No description provided for @trashExpiresSoon.
  ///
  /// In it, this message translates to:
  /// **'Scade tra poco (eliminazione automatica)'**
  String get trashExpiresSoon;

  /// No description provided for @trashExpiresToday.
  ///
  /// In it, this message translates to:
  /// **'Scade oggi'**
  String get trashExpiresToday;

  /// No description provided for @trashExpiresInDays.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{Scade tra 1 giorno} other{Scade tra {count} giorni}}'**
  String trashExpiresInDays(int count);

  /// No description provided for @trashDeleteForever.
  ///
  /// In it, this message translates to:
  /// **'Elimina definitivamente'**
  String get trashDeleteForever;

  /// No description provided for @trashDeleteForeverConfirm.
  ///
  /// In it, this message translates to:
  /// **'La nota verrà eliminata in modo permanente.'**
  String get trashDeleteForeverConfirm;

  /// No description provided for @labelsNew.
  ///
  /// In it, this message translates to:
  /// **'Nuova etichetta'**
  String get labelsNew;

  /// No description provided for @labelsNameHint.
  ///
  /// In it, this message translates to:
  /// **'Nome etichetta'**
  String get labelsNameHint;

  /// No description provided for @labelsEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessuna etichetta'**
  String get labelsEmpty;

  /// No description provided for @labelsEmptyHint.
  ///
  /// In it, this message translates to:
  /// **'Crea una nuova etichetta o aggiungila da una nota.'**
  String get labelsEmptyHint;

  /// No description provided for @labelsRename.
  ///
  /// In it, this message translates to:
  /// **'Rinomina'**
  String get labelsRename;

  /// No description provided for @labelsRenameTitle.
  ///
  /// In it, this message translates to:
  /// **'Rinomina etichetta'**
  String get labelsRenameTitle;

  /// No description provided for @labelsDeleteTitle.
  ///
  /// In it, this message translates to:
  /// **'Elimina etichetta'**
  String get labelsDeleteTitle;

  /// No description provided for @labelsDeleteConfirm.
  ///
  /// In it, this message translates to:
  /// **'L\'etichetta \"{tag}\" verrà rimossa da tutte le note.'**
  String labelsDeleteConfirm(String tag);

  /// No description provided for @labelsNoteCount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =0{Nessuna nota} =1{1 nota} other{{count} note}}'**
  String labelsNoteCount(int count);

  /// No description provided for @labelNotesEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessuna nota con questa etichetta'**
  String get labelNotesEmpty;

  /// No description provided for @editorLabels.
  ///
  /// In it, this message translates to:
  /// **'Etichette'**
  String get editorLabels;

  /// No description provided for @editorLabelsSearchHint.
  ///
  /// In it, this message translates to:
  /// **'Cerca o crea un\'etichetta...'**
  String get editorLabelsSearchHint;

  /// No description provided for @editorLabelsCreate.
  ///
  /// In it, this message translates to:
  /// **'Crea \"{name}\"'**
  String editorLabelsCreate(String name);

  /// No description provided for @editorLabelsEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessuna etichetta: scrivi un nome per crearne una.'**
  String get editorLabelsEmpty;

  /// No description provided for @statsTitle.
  ///
  /// In it, this message translates to:
  /// **'Statistiche'**
  String get statsTitle;

  /// No description provided for @statsNotesActive.
  ///
  /// In it, this message translates to:
  /// **'Attive'**
  String get statsNotesActive;

  /// No description provided for @statsNotesArchived.
  ///
  /// In it, this message translates to:
  /// **'Archiviate'**
  String get statsNotesArchived;

  /// No description provided for @statsNotesTrashed.
  ///
  /// In it, this message translates to:
  /// **'Eliminate'**
  String get statsNotesTrashed;

  /// No description provided for @statsActive.
  ///
  /// In it, this message translates to:
  /// **'Attivi'**
  String get statsActive;

  /// No description provided for @statsArchived.
  ///
  /// In it, this message translates to:
  /// **'Archiviati'**
  String get statsArchived;

  /// No description provided for @statsTrashed.
  ///
  /// In it, this message translates to:
  /// **'Eliminati'**
  String get statsTrashed;

  /// No description provided for @statsBirthdays.
  ///
  /// In it, this message translates to:
  /// **'Compleanni'**
  String get statsBirthdays;

  /// No description provided for @statsNameDays.
  ///
  /// In it, this message translates to:
  /// **'Onomastici'**
  String get statsNameDays;

  /// No description provided for @statsTotal.
  ///
  /// In it, this message translates to:
  /// **'Totali'**
  String get statsTotal;

  /// No description provided for @statsNotesDistribution.
  ///
  /// In it, this message translates to:
  /// **'Distribuzione note'**
  String get statsNotesDistribution;

  /// No description provided for @statsNoNotes.
  ///
  /// In it, this message translates to:
  /// **'Nessuna nota presente'**
  String get statsNoNotes;

  /// No description provided for @statsTasksDistribution.
  ///
  /// In it, this message translates to:
  /// **'Distribuzione task'**
  String get statsTasksDistribution;

  /// No description provided for @statsNoTasks.
  ///
  /// In it, this message translates to:
  /// **'Nessun task presente'**
  String get statsNoTasks;

  /// No description provided for @statsTaskCompletion.
  ///
  /// In it, this message translates to:
  /// **'Completamento task'**
  String get statsTaskCompletion;

  /// No description provided for @statsNoData.
  ///
  /// In it, this message translates to:
  /// **'Nessun dato'**
  String get statsNoData;

  /// No description provided for @statsNoTasksShort.
  ///
  /// In it, this message translates to:
  /// **'Nessun task'**
  String get statsNoTasksShort;

  /// No description provided for @statsTotalSingular.
  ///
  /// In it, this message translates to:
  /// **'Totale'**
  String get statsTotalSingular;

  /// No description provided for @infoTitle.
  ///
  /// In it, this message translates to:
  /// **'Info su Noteep'**
  String get infoTitle;

  /// No description provided for @infoTagline.
  ///
  /// In it, this message translates to:
  /// **'Note, attività e promemoria in un unico posto'**
  String get infoTagline;

  /// No description provided for @infoAboutTitle.
  ///
  /// In it, this message translates to:
  /// **'Cos\'è Noteep'**
  String get infoAboutTitle;

  /// No description provided for @infoFeaturesTitle.
  ///
  /// In it, this message translates to:
  /// **'Funzionalità'**
  String get infoFeaturesTitle;

  /// No description provided for @infoFeatureNotesTitle.
  ///
  /// In it, this message translates to:
  /// **'Note'**
  String get infoFeatureNotesTitle;

  /// No description provided for @infoFeatureNotesText.
  ///
  /// In it, this message translates to:
  /// **'Testo formattato, liste di controllo e note vocali'**
  String get infoFeatureNotesText;

  /// No description provided for @infoFeatureTasksTitle.
  ///
  /// In it, this message translates to:
  /// **'Attività e calendario'**
  String get infoFeatureTasksTitle;

  /// No description provided for @infoFeatureTasksText.
  ///
  /// In it, this message translates to:
  /// **'Organizza impegni ed eventi giorno per giorno'**
  String get infoFeatureTasksText;

  /// No description provided for @infoFeatureRemindersTitle.
  ///
  /// In it, this message translates to:
  /// **'Promemoria'**
  String get infoFeatureRemindersTitle;

  /// No description provided for @infoFeatureRemindersText.
  ///
  /// In it, this message translates to:
  /// **'Notifiche puntuali e widget nella schermata Home'**
  String get infoFeatureRemindersText;

  /// No description provided for @infoFeatureSyncTitle.
  ///
  /// In it, this message translates to:
  /// **'Sincronizzazione e backup'**
  String get infoFeatureSyncTitle;

  /// No description provided for @infoFeatureSyncText.
  ///
  /// In it, this message translates to:
  /// **'Dati sul tuo account, backup ed esportazione in PDF, TXT, JSON, CSV e HTML'**
  String get infoFeatureSyncText;

  /// No description provided for @infoLinksTitle.
  ///
  /// In it, this message translates to:
  /// **'Link'**
  String get infoLinksTitle;

  /// No description provided for @infoLinkSource.
  ///
  /// In it, this message translates to:
  /// **'Codice sorgente'**
  String get infoLinkSource;

  /// No description provided for @infoLinkDeveloper.
  ///
  /// In it, this message translates to:
  /// **'Profilo GitHub'**
  String get infoLinkDeveloper;

  /// No description provided for @infoLinkContact.
  ///
  /// In it, this message translates to:
  /// **'Contatta lo sviluppatore'**
  String get infoLinkContact;

  /// No description provided for @infoLinkError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile aprire il link'**
  String get infoLinkError;

  /// No description provided for @infoMadeBy.
  ///
  /// In it, this message translates to:
  /// **'Realizzato da {name}'**
  String infoMadeBy(String name);

  /// No description provided for @infoGuideOpen.
  ///
  /// In it, this message translates to:
  /// **'Guida introduttiva'**
  String get infoGuideOpen;

  /// No description provided for @infoChangelogTitle.
  ///
  /// In it, this message translates to:
  /// **'Novità'**
  String get infoChangelogTitle;

  /// No description provided for @infoLicensesTitle.
  ///
  /// In it, this message translates to:
  /// **'Licenze open source'**
  String get infoLicensesTitle;

  /// No description provided for @exportTitle.
  ///
  /// In it, this message translates to:
  /// **'Esporta note'**
  String get exportTitle;

  /// No description provided for @exportIntro.
  ///
  /// In it, this message translates to:
  /// **'Esporta tutte le note attive (escluse quelle nel cestino).'**
  String get exportIntro;

  /// No description provided for @exportPdfSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Salva le note in un file .pdf'**
  String get exportPdfSubtitle;

  /// No description provided for @exportTxtSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Salva le note in un file .txt'**
  String get exportTxtSubtitle;

  /// No description provided for @exportJsonSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Salva le note in un file .json'**
  String get exportJsonSubtitle;

  /// No description provided for @exportCsvSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Salva le note in un file .csv'**
  String get exportCsvSubtitle;

  /// No description provided for @exportHtmlSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Salva le note in un file .html'**
  String get exportHtmlSubtitle;

  /// No description provided for @exportDownload.
  ///
  /// In it, this message translates to:
  /// **'Scarica'**
  String get exportDownload;

  /// No description provided for @settingsBackupTitle.
  ///
  /// In it, this message translates to:
  /// **'Backup'**
  String get settingsBackupTitle;

  /// No description provided for @settingsAutoBackup.
  ///
  /// In it, this message translates to:
  /// **'Backup automatico'**
  String get settingsAutoBackup;

  /// No description provided for @settingsAutoBackupSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Salva automaticamente i tuoi dati'**
  String get settingsAutoBackupSubtitle;

  /// No description provided for @settingsBackupFrequency.
  ///
  /// In it, this message translates to:
  /// **'Frequenza backup'**
  String get settingsBackupFrequency;

  /// No description provided for @settingsViewBackups.
  ///
  /// In it, this message translates to:
  /// **'Visualizza backup'**
  String get settingsViewBackups;

  /// No description provided for @settingsViewBackupsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Gestisci i backup salvati'**
  String get settingsViewBackupsSubtitle;

  /// No description provided for @settingsExportCalendarJson.
  ///
  /// In it, this message translates to:
  /// **'Esporta calendario JSON'**
  String get settingsExportCalendarJson;

  /// No description provided for @settingsExportCalendarJsonSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Scarica gli eventi come file .json'**
  String get settingsExportCalendarJsonSubtitle;

  /// No description provided for @settingsImportCalendarJson.
  ///
  /// In it, this message translates to:
  /// **'Importa calendario JSON'**
  String get settingsImportCalendarJson;

  /// No description provided for @settingsImportCalendarJsonSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Ripristina gli eventi da un file .json'**
  String get settingsImportCalendarJsonSubtitle;

  /// No description provided for @settingsExportIcs.
  ///
  /// In it, this message translates to:
  /// **'Esporta calendario ICS'**
  String get settingsExportIcs;

  /// No description provided for @settingsExportIcsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Esporta tutti gli eventi in un file .ics'**
  String get settingsExportIcsSubtitle;

  /// No description provided for @settingsImportIcs.
  ///
  /// In it, this message translates to:
  /// **'Importa da Google Calendar'**
  String get settingsImportIcs;

  /// No description provided for @settingsImportIcsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Importa eventi da un file .ics'**
  String get settingsImportIcsSubtitle;

  /// No description provided for @settingsClearCalendar.
  ///
  /// In it, this message translates to:
  /// **'Cancella eventi calendario'**
  String get settingsClearCalendar;

  /// No description provided for @settingsClearCalendarSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Rimuove tutti gli eventi dal calendario'**
  String get settingsClearCalendarSubtitle;

  /// No description provided for @settingsGlobalBackupTitle.
  ///
  /// In it, this message translates to:
  /// **'Backup globale'**
  String get settingsGlobalBackupTitle;

  /// No description provided for @settingsExportFullBackup.
  ///
  /// In it, this message translates to:
  /// **'Esporta backup completo'**
  String get settingsExportFullBackup;

  /// No description provided for @settingsExportFullBackupSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Scarica un file .json con note, task ed eventi'**
  String get settingsExportFullBackupSubtitle;

  /// No description provided for @settingsImportFullBackup.
  ///
  /// In it, this message translates to:
  /// **'Importa backup completo'**
  String get settingsImportFullBackup;

  /// No description provided for @settingsImportFullBackupSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Ripristina dati da un file .json di backup'**
  String get settingsImportFullBackupSubtitle;

  /// No description provided for @settingsClearAll.
  ///
  /// In it, this message translates to:
  /// **'Cancella tutti i dati'**
  String get settingsClearAll;

  /// No description provided for @settingsClearAllSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Elimina definitivamente note, task ed eventi'**
  String get settingsClearAllSubtitle;

  /// No description provided for @settingsAccountTitle.
  ///
  /// In it, this message translates to:
  /// **'Account'**
  String get settingsAccountTitle;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In it, this message translates to:
  /// **'Elimina account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Elimina definitivamente l\'account e tutti i suoi dati'**
  String get settingsDeleteAccountSubtitle;

  /// No description provided for @settingsNotesDataTitle.
  ///
  /// In it, this message translates to:
  /// **'Dati note'**
  String get settingsNotesDataTitle;

  /// No description provided for @settingsStatisticsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Visualizza tutte le informazioni sulle tue note'**
  String get settingsStatisticsSubtitle;

  /// No description provided for @settingsExportNotesSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Esporta tutte le note in diversi formati'**
  String get settingsExportNotesSubtitle;

  /// No description provided for @settingsExportNotesJson.
  ///
  /// In it, this message translates to:
  /// **'Esporta note JSON'**
  String get settingsExportNotesJson;

  /// No description provided for @settingsExportNotesJsonSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Scarica le note come file .json'**
  String get settingsExportNotesJsonSubtitle;

  /// No description provided for @settingsImportNotesJson.
  ///
  /// In it, this message translates to:
  /// **'Importa note JSON'**
  String get settingsImportNotesJson;

  /// No description provided for @settingsImportNotesJsonSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Ripristina le note da un file .json'**
  String get settingsImportNotesJsonSubtitle;

  /// No description provided for @settingsClearNotes.
  ///
  /// In it, this message translates to:
  /// **'Cancella note'**
  String get settingsClearNotes;

  /// No description provided for @settingsClearNotesSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Rimuove tutte le note'**
  String get settingsClearNotesSubtitle;

  /// No description provided for @settingsLayout.
  ///
  /// In it, this message translates to:
  /// **'Layout'**
  String get settingsLayout;

  /// No description provided for @settingsLayoutGrid.
  ///
  /// In it, this message translates to:
  /// **'Griglia'**
  String get settingsLayoutGrid;

  /// No description provided for @settingsLayoutList.
  ///
  /// In it, this message translates to:
  /// **'Lista'**
  String get settingsLayoutList;

  /// No description provided for @settingsFabMenu.
  ///
  /// In it, this message translates to:
  /// **'Menu del pulsante +'**
  String get settingsFabMenu;

  /// No description provided for @settingsFabMenuOn.
  ///
  /// In it, this message translates to:
  /// **'Scegli tra nota, lista, task, audio e modello'**
  String get settingsFabMenuOn;

  /// No description provided for @settingsFabMenuOff.
  ///
  /// In it, this message translates to:
  /// **'Il pulsante + crea subito una nuova nota'**
  String get settingsFabMenuOff;

  /// No description provided for @settingsExportTasksJson.
  ///
  /// In it, this message translates to:
  /// **'Esporta task JSON'**
  String get settingsExportTasksJson;

  /// No description provided for @settingsExportTasksJsonSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Scarica i task come file .json'**
  String get settingsExportTasksJsonSubtitle;

  /// No description provided for @settingsImportTasksJson.
  ///
  /// In it, this message translates to:
  /// **'Importa task JSON'**
  String get settingsImportTasksJson;

  /// No description provided for @settingsImportTasksJsonSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Ripristina i task da un file .json'**
  String get settingsImportTasksJsonSubtitle;

  /// No description provided for @settingsClearTasks.
  ///
  /// In it, this message translates to:
  /// **'Cancella task'**
  String get settingsClearTasks;

  /// No description provided for @settingsClearTasksSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Rimuove tutti i task'**
  String get settingsClearTasksSubtitle;

  /// No description provided for @settingsShowCompleted.
  ///
  /// In it, this message translates to:
  /// **'Mostra task completati'**
  String get settingsShowCompleted;

  /// No description provided for @settingsShowCompletedSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Visualizza i task marcati come completati'**
  String get settingsShowCompletedSubtitle;

  /// No description provided for @settingsGroupByPriority.
  ///
  /// In it, this message translates to:
  /// **'Raggruppa per priorità'**
  String get settingsGroupByPriority;

  /// No description provided for @settingsGroupByPrioritySubtitle.
  ///
  /// In it, this message translates to:
  /// **'Ordina task per priorità (speciali in alto)'**
  String get settingsGroupByPrioritySubtitle;

  /// No description provided for @settingsRestoreBackup.
  ///
  /// In it, this message translates to:
  /// **'Ripristina backup'**
  String get settingsRestoreBackup;

  /// No description provided for @settingsReplaceAllConfirm.
  ///
  /// In it, this message translates to:
  /// **'I dati attuali (note, task ed eventi) verranno sostituiti con quelli del backup. Continuare?'**
  String get settingsReplaceAllConfirm;

  /// No description provided for @settingsBackupReadFailed.
  ///
  /// In it, this message translates to:
  /// **'Impossibile leggere il backup.'**
  String get settingsBackupReadFailed;

  /// No description provided for @settingsBackupRestored.
  ///
  /// In it, this message translates to:
  /// **'Backup ripristinato con successo.'**
  String get settingsBackupRestored;

  /// No description provided for @settingsNoBackups.
  ///
  /// In it, this message translates to:
  /// **'Nessun backup disponibile'**
  String get settingsNoBackups;

  /// No description provided for @settingsBackupsAvailable.
  ///
  /// In it, this message translates to:
  /// **'Backup disponibili'**
  String get settingsBackupsAvailable;

  /// No description provided for @settingsImport.
  ///
  /// In it, this message translates to:
  /// **'Importa'**
  String get settingsImport;

  /// No description provided for @settingsBackupExported.
  ///
  /// In it, this message translates to:
  /// **'Backup esportato'**
  String get settingsBackupExported;

  /// No description provided for @settingsBackupSavedIn.
  ///
  /// In it, this message translates to:
  /// **'Backup salvato in:\n'**
  String get settingsBackupSavedIn;

  /// No description provided for @settingsImportBackupTitle.
  ///
  /// In it, this message translates to:
  /// **'Importa backup'**
  String get settingsImportBackupTitle;

  /// No description provided for @settingsBackupImported.
  ///
  /// In it, this message translates to:
  /// **'Backup importato con successo.'**
  String get settingsBackupImported;

  /// No description provided for @settingsClearAllConfirm.
  ///
  /// In it, this message translates to:
  /// **'Tutti i dati (note, task ed eventi) verranno eliminati definitivamente. Questa operazione è irreversibile. Continuare?'**
  String get settingsClearAllConfirm;

  /// No description provided for @settingsAllCleared.
  ///
  /// In it, this message translates to:
  /// **'Tutti i dati sono stati eliminati.'**
  String get settingsAllCleared;

  /// No description provided for @settingsDeleteAll.
  ///
  /// In it, this message translates to:
  /// **'Elimina tutto'**
  String get settingsDeleteAll;

  /// No description provided for @settingsNotesExported.
  ///
  /// In it, this message translates to:
  /// **'Note esportate'**
  String get settingsNotesExported;

  /// No description provided for @settingsNotesSavedIn.
  ///
  /// In it, this message translates to:
  /// **'Note salvate in:\n'**
  String get settingsNotesSavedIn;

  /// No description provided for @settingsImportNotesTitle.
  ///
  /// In it, this message translates to:
  /// **'Importa note'**
  String get settingsImportNotesTitle;

  /// No description provided for @settingsReplaceNotesConfirm.
  ///
  /// In it, this message translates to:
  /// **'Le note attuali verranno sostituite con quelle del file. Continuare?'**
  String get settingsReplaceNotesConfirm;

  /// No description provided for @settingsNotesImported.
  ///
  /// In it, this message translates to:
  /// **'Note importate con successo.'**
  String get settingsNotesImported;

  /// No description provided for @settingsClearNotesConfirm.
  ///
  /// In it, this message translates to:
  /// **'Tutte le note verranno eliminate definitivamente. Continuare?'**
  String get settingsClearNotesConfirm;

  /// No description provided for @settingsNotesCleared.
  ///
  /// In it, this message translates to:
  /// **'Tutte le note sono state eliminate.'**
  String get settingsNotesCleared;

  /// No description provided for @settingsTasksExported.
  ///
  /// In it, this message translates to:
  /// **'Task esportati'**
  String get settingsTasksExported;

  /// No description provided for @settingsTasksSavedIn.
  ///
  /// In it, this message translates to:
  /// **'Task salvati in:\n'**
  String get settingsTasksSavedIn;

  /// No description provided for @settingsImportTasksTitle.
  ///
  /// In it, this message translates to:
  /// **'Importa task'**
  String get settingsImportTasksTitle;

  /// No description provided for @settingsReplaceTasksConfirm.
  ///
  /// In it, this message translates to:
  /// **'I task attuali verranno sostituiti con quelli del file. Continuare?'**
  String get settingsReplaceTasksConfirm;

  /// No description provided for @settingsTasksImported.
  ///
  /// In it, this message translates to:
  /// **'Task importati con successo.'**
  String get settingsTasksImported;

  /// No description provided for @settingsClearTasksConfirm.
  ///
  /// In it, this message translates to:
  /// **'Tutti i task verranno eliminati definitivamente. Continuare?'**
  String get settingsClearTasksConfirm;

  /// No description provided for @settingsTasksCleared.
  ///
  /// In it, this message translates to:
  /// **'Tutti i task sono stati eliminati.'**
  String get settingsTasksCleared;

  /// No description provided for @settingsCalendarExported.
  ///
  /// In it, this message translates to:
  /// **'Calendario esportato'**
  String get settingsCalendarExported;

  /// No description provided for @settingsCalendarSavedIn.
  ///
  /// In it, this message translates to:
  /// **'Calendario salvato in:\n'**
  String get settingsCalendarSavedIn;

  /// No description provided for @settingsImportCalendarTitle.
  ///
  /// In it, this message translates to:
  /// **'Importa calendario'**
  String get settingsImportCalendarTitle;

  /// No description provided for @settingsReplaceCalendarConfirm.
  ///
  /// In it, this message translates to:
  /// **'Gli eventi attuali verranno sostituiti con quelli del file. Continuare?'**
  String get settingsReplaceCalendarConfirm;

  /// No description provided for @settingsCalendarImported.
  ///
  /// In it, this message translates to:
  /// **'Calendario importato con successo.'**
  String get settingsCalendarImported;

  /// No description provided for @settingsClearEventsTitle.
  ///
  /// In it, this message translates to:
  /// **'Cancella eventi'**
  String get settingsClearEventsTitle;

  /// No description provided for @settingsClearCalendarConfirm.
  ///
  /// In it, this message translates to:
  /// **'Tutti gli eventi del calendario verranno eliminati definitivamente. Continuare?'**
  String get settingsClearCalendarConfirm;

  /// No description provided for @settingsCalendarCleared.
  ///
  /// In it, this message translates to:
  /// **'Tutti gli eventi sono stati eliminati.'**
  String get settingsCalendarCleared;

  /// No description provided for @settingsNoEventsToExport.
  ///
  /// In it, this message translates to:
  /// **'Nessun evento da esportare.'**
  String get settingsNoEventsToExport;

  /// No description provided for @settingsIcsDownloaded.
  ///
  /// In it, this message translates to:
  /// **'Calendario ICS scaricato'**
  String get settingsIcsDownloaded;

  /// No description provided for @settingsIcsExported.
  ///
  /// In it, this message translates to:
  /// **'Calendario ICS esportato'**
  String get settingsIcsExported;

  /// No description provided for @settingsNoEventsInFile.
  ///
  /// In it, this message translates to:
  /// **'Nessun evento trovato nel file.'**
  String get settingsNoEventsInFile;

  /// No description provided for @settingsDeleteAccountConfirm.
  ///
  /// In it, this message translates to:
  /// **'L\'account e tutti i suoi dati (note, task ed eventi) verranno eliminati definitivamente da tutti i dispositivi. Questa operazione è irreversibile: se vuoi conservare i dati, esporta prima un backup completo. Continuare?'**
  String get settingsDeleteAccountConfirm;

  /// No description provided for @settingsConfirmPassword.
  ///
  /// In it, this message translates to:
  /// **'Conferma la password'**
  String get settingsConfirmPassword;

  /// No description provided for @settingsDeleteAccountFailed.
  ///
  /// In it, this message translates to:
  /// **'Impossibile eliminare l\'account. Controlla la connessione e riprova.'**
  String get settingsDeleteAccountFailed;

  /// No description provided for @settingsAccountDeleted.
  ///
  /// In it, this message translates to:
  /// **'Account eliminato.'**
  String get settingsAccountDeleted;

  /// No description provided for @settingsImportError.
  ///
  /// In it, this message translates to:
  /// **'Errore durante l\'importazione: {error}'**
  String settingsImportError(String error);

  /// No description provided for @settingsBackupsLoadError.
  ///
  /// In it, this message translates to:
  /// **'Errore nel caricamento dei backup: {error}'**
  String settingsBackupsLoadError(String error);

  /// No description provided for @settingsIcsSavedIn.
  ///
  /// In it, this message translates to:
  /// **'Calendario ICS salvato in:\n{path}'**
  String settingsIcsSavedIn(String path);

  /// No description provided for @settingsIcsImported.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 evento importato nel calendario.} other{{count} eventi importati nel calendario.}}'**
  String settingsIcsImported(int count);

  /// No description provided for @infoVersion.
  ///
  /// In it, this message translates to:
  /// **'Versione {version}'**
  String infoVersion(String version);

  /// No description provided for @infoDescription.
  ///
  /// In it, this message translates to:
  /// **'Noteep raccoglie note, liste di controllo, attività ed eventi del calendario, sincronizzati sul tuo account e disponibili su ogni dispositivo.'**
  String get infoDescription;

  /// No description provided for @statsCompletedOf.
  ///
  /// In it, this message translates to:
  /// **'Completati: {completed} / {total}'**
  String statsCompletedOf(int completed, int total);

  /// No description provided for @exportPdfError.
  ///
  /// In it, this message translates to:
  /// **'Errore PDF: {error}'**
  String exportPdfError(String error);

  /// No description provided for @exportEmptyNote.
  ///
  /// In it, this message translates to:
  /// **'(nota vuota)'**
  String get exportEmptyNote;

  /// No description provided for @exportModified.
  ///
  /// In it, this message translates to:
  /// **'Modificata: {date}'**
  String exportModified(String date);

  /// No description provided for @exportLabels.
  ///
  /// In it, this message translates to:
  /// **'Etichette: {labels}'**
  String exportLabels(String labels);

  /// No description provided for @exportDateTimePattern.
  ///
  /// In it, this message translates to:
  /// **'d MMM y \'alle\' HH:mm'**
  String get exportDateTimePattern;

  /// No description provided for @exportCsvHeader.
  ///
  /// In it, this message translates to:
  /// **'id,titolo,contenuto,tipo,etichette,fissata,creata,modificata'**
  String get exportCsvHeader;

  /// No description provided for @exportHtmlHeading.
  ///
  /// In it, this message translates to:
  /// **'Export note – {date}'**
  String exportHtmlHeading(String date);

  /// No description provided for @notificationChannelName.
  ///
  /// In it, this message translates to:
  /// **'Promemoria'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In it, this message translates to:
  /// **'Notifiche per i promemoria di Noteep'**
  String get notificationChannelDescription;

  /// No description provided for @notificationTargetNotFound.
  ///
  /// In it, this message translates to:
  /// **'Elemento del promemoria non trovato'**
  String get notificationTargetNotFound;

  /// No description provided for @widgetNoteCount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 nota} other{{count} note}}'**
  String widgetNoteCount(int count);

  /// No description provided for @widgetTaskCount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 task} other{{count} task}}'**
  String widgetTaskCount(int count);

  /// No description provided for @widgetNoRecentNote.
  ///
  /// In it, this message translates to:
  /// **'Nessuna nota recente'**
  String get widgetNoRecentNote;

  /// No description provided for @changelog_v2_0_0_bullet_33.
  ///
  /// In it, this message translates to:
  /// **'Il widget per la schermata Home ora si aggiorna davvero con il numero di note e task e con l\'ultima nota modificata, nella lingua dell\'app.'**
  String get changelog_v2_0_0_bullet_33;

  /// No description provided for @changelog_v2_0_0_bullet_34.
  ///
  /// In it, this message translates to:
  /// **'Nuova informativa sulla privacy, leggibile direttamente nell\'app da Info su Noteep, in italiano e in inglese.'**
  String get changelog_v2_0_0_bullet_34;

  /// No description provided for @changelog_v2_0_0_bullet_35.
  ///
  /// In it, this message translates to:
  /// **'Schermata Info su Noteep rinnovata: funzionalità principali in evidenza e nuovi link al codice sorgente, al profilo GitHub e al contatto dello sviluppatore.'**
  String get changelog_v2_0_0_bullet_35;

  /// No description provided for @changelog_v2_0_0_bullet_36.
  ///
  /// In it, this message translates to:
  /// **'Il ripristino del backup e l\'importazione del calendario sono più sicuri: un file selezionato non può più essere usato per accedere ad altri file del dispositivo.'**
  String get changelog_v2_0_0_bullet_36;

  /// No description provided for @changelog_v2_0_0_bullet_37.
  ///
  /// In it, this message translates to:
  /// **'Il permesso per le notifiche non viene più chiesto all\'apertura dell\'app, ma solo la prima volta che imposti un promemoria.'**
  String get changelog_v2_0_0_bullet_37;

  /// No description provided for @changelog_v2_0_0_bullet_38.
  ///
  /// In it, this message translates to:
  /// **'Nuovi widget per la schermata Home: Azioni rapide, con i pulsanti per creare una nota, un task o un evento, e i widget singoli Nuova nota, Nuovo task e Nuovo evento.'**
  String get changelog_v2_0_0_bullet_38;

  /// No description provided for @changelog_v2_0_0_bullet_39.
  ///
  /// In it, this message translates to:
  /// **'Toccare il widget Noteep nella schermata Home ora apre l\'app.'**
  String get changelog_v2_0_0_bullet_39;

  /// No description provided for @changelog_v2_0_0_bullet_40.
  ///
  /// In it, this message translates to:
  /// **'Dopo aver reinstallato l\'app non devi più accedere di nuovo a ogni riapertura: l\'accesso resta attivo.'**
  String get changelog_v2_0_0_bullet_40;

  /// No description provided for @changelog_v2_0_0_bullet_41.
  ///
  /// In it, this message translates to:
  /// **'I promemoria funzionano di nuovo: impostarne uno non mostra più l\'errore \"Impossibile pianificare il promemoria\" e la notifica arriva all\'orario scelto.'**
  String get changelog_v2_0_0_bullet_41;

  /// No description provided for @changelog_v2_0_0_bullet_42.
  ///
  /// In it, this message translates to:
  /// **'Quando scrivi titoli, note, task, sottotask, eventi ed etichette la prima lettera ora è maiuscola in automatico.'**
  String get changelog_v2_0_0_bullet_42;

  /// No description provided for @changelog_v2_0_0_bullet_43.
  ///
  /// In it, this message translates to:
  /// **'Gli eventi del calendario possono avere un solo orario: l\'ora di fine ora è facoltativa e puoi sceglierla tu.'**
  String get changelog_v2_0_0_bullet_43;

  /// No description provided for @changelog_v2_0_0_bullet_44.
  ///
  /// In it, this message translates to:
  /// **'Etichette più utili: aggiungile a una nota dal menu dell\'editor e tocca un\'etichetta nella sezione Etichette per vedere le note che la usano. Ora sono salvate nel tuo account, quindi le ritrovi su ogni dispositivo.'**
  String get changelog_v2_0_0_bullet_44;

  /// No description provided for @changelog_v2_0_0_bullet_45.
  ///
  /// In it, this message translates to:
  /// **'Nella sezione Promemoria puoi rimuovere in un colpo tutti i promemoria scaduti, e se ne togli uno per sbaglio basta toccare Annulla per rimetterlo.'**
  String get changelog_v2_0_0_bullet_45;

  /// No description provided for @changelog_v2_0_0_bullet_46.
  ///
  /// In it, this message translates to:
  /// **'In Info e nelle Impostazioni la versione dell\'app è mostrata in modo più semplice, senza il numero di build.'**
  String get changelog_v2_0_0_bullet_46;

  /// No description provided for @changelog_v2_0_0_bullet_47.
  ///
  /// In it, this message translates to:
  /// **'Dalle Impostazioni è stata tolta la voce Google Drive, che non era ancora attiva: tornerà quando la funzione sarà pronta.'**
  String get changelog_v2_0_0_bullet_47;

  /// No description provided for @changelog_v2_0_0_bullet_48.
  ///
  /// In it, this message translates to:
  /// **'Nelle Impostazioni tema e lingua si scelgono con dei comodi pulsanti affiancati, invece che da un elenco.'**
  String get changelog_v2_0_0_bullet_48;

  /// No description provided for @changelog_v2_0_0_bullet_49.
  ///
  /// In it, this message translates to:
  /// **'Nella schermata principale le note scritte con la formattazione mostrano il testo pulito, senza simboli come asterischi o cancelletti. Lo stesso vale per l\'anteprima dei promemoria e per l\'elenco delle note da collegare.'**
  String get changelog_v2_0_0_bullet_49;

  /// No description provided for @changelog_v2_0_0_bullet_50.
  ///
  /// In it, this message translates to:
  /// **'Le note fissate compaiono sempre in cima alla schermata principale, qualunque sia l\'ordinamento scelto.'**
  String get changelog_v2_0_0_bullet_50;

  /// No description provided for @infoPrivacyOpen.
  ///
  /// In it, this message translates to:
  /// **'Informativa sulla privacy'**
  String get infoPrivacyOpen;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In it, this message translates to:
  /// **'Informativa sulla privacy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyIntro.
  ///
  /// In it, this message translates to:
  /// **'Noteep è un\'app per note, task e calendario. Questa informativa spiega quali dati tratta, perché e come puoi controllarli. Noteep non mostra pubblicità, non usa strumenti di analisi o di tracciamento e non vende né cede i tuoi dati.'**
  String get privacyPolicyIntro;

  /// No description provided for @privacyPolicyLastUpdated.
  ///
  /// In it, this message translates to:
  /// **'Ultimo aggiornamento: {date}'**
  String privacyPolicyLastUpdated(String date);

  /// No description provided for @privacyPolicyOnlineVersion.
  ///
  /// In it, this message translates to:
  /// **'Versione online'**
  String get privacyPolicyOnlineVersion;

  /// No description provided for @privacyPolicyOnlineVersionSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Leggi l\'informativa sul web'**
  String get privacyPolicyOnlineVersionSubtitle;

  /// No description provided for @policy_section_controller_title.
  ///
  /// In it, this message translates to:
  /// **'1. Titolare del trattamento'**
  String get policy_section_controller_title;

  /// No description provided for @policy_section_controller_text.
  ///
  /// In it, this message translates to:
  /// **'Il titolare del trattamento è {name}, sviluppatore di Noteep. Per qualsiasi domanda sulla privacy o per esercitare i tuoi diritti puoi scrivere a {email}.'**
  String policy_section_controller_text(String name, String email);

  /// No description provided for @policy_section_data_title.
  ///
  /// In it, this message translates to:
  /// **'2. Dati che raccogliamo'**
  String get policy_section_data_title;

  /// No description provided for @policy_section_data_text.
  ///
  /// In it, this message translates to:
  /// **'• Account: l\'indirizzo email con cui ti registri; la password è gestita da Firebase Authentication e non è mai visibile allo sviluppatore. Se accedi con Google, Google condivide con Firebase nome, email, foto del profilo e identificativo del tuo account Google. Firebase registra anche la data di creazione dell\'account e dell\'ultimo accesso.\n• Contenuti: note (titolo, testo, liste di controllo, etichette, colori e stile, promemoria, collegamenti tra note, cronologia delle modifiche), task ed elenchi (sottotask, scadenze, ricorrenze, priorità) ed eventi del calendario.\n• Note audio: le registrazioni restano solo sul dispositivo; con la nota vengono sincronizzati soltanto nome, durata e percorso del file.\n• Sul dispositivo: preferenze dell\'app (lingua, tema, layout, ordinamento, etichette personalizzate, opzioni di note e task, guida introduttiva e novità già viste, impostazioni dei backup), i backup automatici, una copia dei dati per l\'uso offline, i promemoria programmati e i dati mostrati dal widget della schermata Home (numero di note e task, titolo dell\'ultima nota). Sul web le preferenze sono salvate nel browser.'**
  String get policy_section_data_text;

  /// No description provided for @policy_section_use_title.
  ///
  /// In it, this message translates to:
  /// **'3. Come usiamo i dati'**
  String get policy_section_use_title;

  /// No description provided for @policy_section_use_text.
  ///
  /// In it, this message translates to:
  /// **'I dati servono solo a far funzionare Noteep: accedere al tuo account, salvare i tuoi contenuti e sincronizzarli tra i tuoi dispositivi, inviarti i promemoria che imposti e creare i backup. La tua email viene usata solo per l\'accesso e, se lo chiedi, per inviarti il link per reimpostare la password. Nessuna profilazione, nessuna pubblicità, nessuna analisi statistica né segnalazione automatica degli errori.'**
  String get policy_section_use_text;

  /// No description provided for @policy_section_storage_title.
  ///
  /// In it, this message translates to:
  /// **'4. Dove sono conservati'**
  String get policy_section_storage_title;

  /// No description provided for @policy_section_storage_text.
  ///
  /// In it, this message translates to:
  /// **'Account e contenuti sono conservati su Google Firebase (Firebase Authentication e Cloud Firestore), servizi forniti da Google. I server possono trovarsi anche fuori dall\'Unione europea: in questo caso il trasferimento avviene con le garanzie previste dai termini di Google Firebase. I dati viaggiano cifrati e le regole di sicurezza del database fanno sì che solo il tuo account possa leggere e modificare i tuoi contenuti. Lo sviluppatore non consulta i tuoi contenuti e non li condivide con nessuno.'**
  String get policy_section_storage_text;

  /// No description provided for @policy_section_device_title.
  ///
  /// In it, this message translates to:
  /// **'5. Elaborazione sul dispositivo'**
  String get policy_section_device_title;

  /// No description provided for @policy_section_device_text.
  ///
  /// In it, this message translates to:
  /// **'Alcune funzioni lavorano solo sul dispositivo e non inviano nulla allo sviluppatore né a terzi:\n• registrazione e riproduzione delle note audio;\n• esportazione delle note in PDF, TXT, JSON, CSV e HTML, esportazione e importazione di backup e calendari (ICS);\n• backup automatici, salvati in una cartella privata dell\'app (al massimo gli ultimi 30);\n• statistiche, promemoria e widget della schermata Home.\nI file che esporti o condividi finiscono dove scegli tu (ad esempio una cartella o un\'altra app).'**
  String get policy_section_device_text;

  /// No description provided for @policy_section_permissions_title.
  ///
  /// In it, this message translates to:
  /// **'6. Permessi'**
  String get policy_section_permissions_title;

  /// No description provided for @policy_section_permissions_text.
  ///
  /// In it, this message translates to:
  /// **'Su Android Noteep usa questi permessi:\n• Microfono: solo per registrare le note audio, quando avvii una registrazione.\n• Notifiche: per mostrarti i promemoria.\n• Sveglie e promemoria esatti: per far scattare i promemoria all\'orario impostato.\n• Avvio all\'accensione: per riprogrammare i promemoria dopo il riavvio del telefono.\n• Mantenere attivo il dispositivo e vibrazione: per consegnare i promemoria anche in standby.\n• Servizio in primo piano: richiesto dal componente di Android che esegue le attività in background, come l\'aggiornamento del widget della schermata Home.\n• Internet e stato della rete: per sincronizzare i dati con Firebase e capire quando sei offline.\nNoteep non accede a posizione, contatti, fotocamera, foto o file del telefono: i file da importare li scegli tu dal selettore di sistema.'**
  String get policy_section_permissions_text;

  /// No description provided for @policy_section_retention_title.
  ///
  /// In it, this message translates to:
  /// **'7. Conservazione e cancellazione'**
  String get policy_section_retention_title;

  /// No description provided for @policy_section_retention_text.
  ///
  /// In it, this message translates to:
  /// **'I tuoi dati restano finché mantieni l\'account. Gli elementi nel cestino vengono eliminati definitivamente dopo 7 giorni. Puoi eliminare l\'account e tutti i dati da Impostazioni > Account > Elimina account: vengono cancellati l\'account e i contenuti su Firebase e, su questo dispositivo, i promemoria e i backup automatici. Prima puoi esportare tutto da Impostazioni > Backup globale. Eventuali copie residue nei sistemi di Google vengono rimosse nei tempi previsti da Firebase. Uscire dall\'account non cancella i dati; disinstallando l\'app vengono rimossi i dati salvati sul dispositivo, comprese le note audio. Puoi anche chiedere la cancellazione scrivendo a {email}.'**
  String policy_section_retention_text(String email);

  /// No description provided for @policy_section_rights_title.
  ///
  /// In it, this message translates to:
  /// **'8. I tuoi diritti'**
  String get policy_section_rights_title;

  /// No description provided for @policy_section_rights_text.
  ///
  /// In it, this message translates to:
  /// **'In base al GDPR hai diritto di:\n• accedere ai tuoi dati ed esportarli (anche direttamente dall\'app);\n• correggerli;\n• cancellarli;\n• chiedere informazioni su come vengono trattati.\nPer esercitarli scrivi a {email}. Hai anche il diritto di presentare reclamo all\'autorità di controllo del tuo Paese (in Italia il Garante per la protezione dei dati personali).'**
  String policy_section_rights_text(String email);

  /// No description provided for @policy_section_children_title.
  ///
  /// In it, this message translates to:
  /// **'9. Minori'**
  String get policy_section_children_title;

  /// No description provided for @policy_section_children_text.
  ///
  /// In it, this message translates to:
  /// **'Noteep non è rivolta ai minori di 14 anni, l\'età minima in Italia per acconsentire da soli ai servizi online. Sotto questa età puoi usarla solo con il consenso di un genitore o di chi ne fa le veci. Nei Paesi che prevedono un\'età diversa vale quella stabilita dalla legge locale.'**
  String get policy_section_children_text;

  /// No description provided for @policy_section_changes_title.
  ///
  /// In it, this message translates to:
  /// **'10. Modifiche'**
  String get policy_section_changes_title;

  /// No description provided for @policy_section_changes_text.
  ///
  /// In it, this message translates to:
  /// **'Se questa informativa cambia, la nuova versione sarà disponibile nell\'app (Info app > Informativa sulla privacy) e online, con la data dell\'ultimo aggiornamento.'**
  String get policy_section_changes_text;
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
