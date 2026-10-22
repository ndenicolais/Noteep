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
