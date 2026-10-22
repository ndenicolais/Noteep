// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsAppearanceTitle => 'Appearance';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageSystem => 'System language';

  @override
  String get changelog_dialog_title => 'What\'s new';

  @override
  String get changelog_dialog_close => 'Close';

  @override
  String get changelog_section_added => 'New';

  @override
  String get changelog_section_improved => 'Improvements';

  @override
  String get changelog_section_fixed => 'Fixes';

  @override
  String get changelog_section_security => 'Security';

  @override
  String get changelog_v2_0_0_bullet_1 =>
      'Completely redesigned app: notes, tasks and calendar in one place, synced to your account.';

  @override
  String get changelog_v2_0_0_bullet_2 =>
      'Notes with custom styles, Markdown, checklists, audio notes, links between notes and 6 ready-made templates.';

  @override
  String get changelog_v2_0_0_bullet_3 =>
      'Tasks with lists, subtasks, due dates, recurrences and special tasks.';

  @override
  String get changelog_v2_0_0_bullet_4 =>
      'New calendar with day, week, month, year and schedule views, birthdays and name days, ICS import and export.';

  @override
  String get changelog_v2_0_0_bullet_5 =>
      'Reminders for notes, tasks and events, with a dedicated screen.';

  @override
  String get changelog_v2_0_0_bullet_6 =>
      'Labels, archive and trash with automatic deletion after 7 days.';

  @override
  String get changelog_v2_0_0_bullet_7 =>
      'Statistics, note export to PDF, TXT, JSON, CSV and HTML, manual and automatic backups.';

  @override
  String get changelog_v2_0_0_bullet_8 => 'Widget for the Android home screen.';

  @override
  String get changelog_v2_0_0_bullet_9 =>
      '\"Undo\" button after moving notes, tasks and events to the trash or archive.';

  @override
  String get changelog_v2_0_0_bullet_10 =>
      'Deleting a note or a task from the editor now moves it to the trash instead of deleting it permanently.';

  @override
  String get changelog_v2_0_0_bullet_11 =>
      'Pull down on notes and tasks to refresh them, for example after a connection error or changes made on another device.';

  @override
  String get changelog_v2_0_0_bullet_12 =>
      '\"Retry\" button when syncing fails and \"Create your first note\" when you don\'t have any yet.';

  @override
  String get changelog_v2_0_0_bullet_13 =>
      'Swipe a task right to complete it or left to move it to the trash; in list view, swipe a note right to archive it or left to trash it.';

  @override
  String get changelog_v2_0_0_bullet_14 =>
      'Date and time pickers, system menus and dates in the app\'s language.';

  @override
  String get changelog_v2_0_0_bullet_15 =>
      'If the app fails to start, a message with a Retry button appears instead of a blank screen.';

  @override
  String get changelog_v2_0_0_bullet_16 =>
      'A first-launch introduction that presents the app\'s features, always available from App info.';

  @override
  String get changelog_v2_0_0_bullet_17 =>
      'Restore automatic backups: in Settings, open the backup list and tap the one to restore.';

  @override
  String get changelog_v2_0_0_bullet_18 =>
      'Importing a full backup now really removes notes, tasks and events that are not part of it, instead of having them reappear after a restart.';

  @override
  String get changelog_v2_0_0_bullet_19 =>
      'ICS calendar: exported recurring events keep their end date, imported ones no longer lose the last occurrence across a daylight saving change, times with an explicit time zone stay correct and text with backslashes is read properly.';

  @override
  String get changelog_v2_0_0_bullet_20 =>
      'While notes and tasks load for the first time, a preview of the list appears instead of the spinner, with a smoother transition between loading, list and empty screen.';

  @override
  String get changelog_v2_0_0_bullet_21 =>
      'New \"masonry\" Home grid: each note takes only the space it needs, with no gaps between short notes and without cutting long ones.';

  @override
  String get changelog_v2_0_0_bullet_22 =>
      'Tapping a reminder notification opens the linked note, task or event directly, even when the app is closed.';

  @override
  String get changelog_v2_0_0_bullet_23 =>
      'Smoother animations: a note expands from its card when you open it and switching between menu sections fades. They stay off when the system\'s reduced animations are on.';

  @override
  String get changelog_v2_0_0_bullet_24 =>
      'Accessibility: with TalkBack each note is read in full and the quick actions (pin, archive, trash, move) are in the Actions menu; with very large system text, cards and fields are no longer cut off, and bottom sheets no longer end up under the navigation bar.';

  @override
  String get changelog_v2_0_0_bullet_25 =>
      'Offline mode: changes made without a connection are saved on the device and sent as soon as you are back online, with a notice while they are pending. On the web, data stays available offline too.';

  @override
  String get changelog_v2_0_0_bullet_26 =>
      'A more consistent look: section headers, settings items, archive and trash items and labels now share the same style across the app, and delete confirmations always use the red button.';

  @override
  String get changelog_v2_0_0_bullet_27 =>
      'New app icon: the light bulb with a check mark on a dark background, which adapts to the shape chosen by the launcher and to the color themes of Android 13 and later.';

  @override
  String get changelog_v2_0_0_bullet_28 =>
      'The new app logo also appears on the sign-in and sign-up screen, the loading screen and the Info page.';

  @override
  String get changelog_v2_0_0_bullet_29 =>
      'Links in notes: with the \"Insert link\" button you add a link to a website, and in the Markdown preview you just tap it to open it in the browser. Addresses typed by hand become clickable too.';

  @override
  String get changelog_v2_0_0_bullet_30 =>
      'Account deletion: in Settings, after confirming your password or Google account, you can permanently delete your account together with all your notes, tasks and events.';

  @override
  String get changelog_v2_0_0_bullet_31 =>
      'New option in Settings > Notes: choose whether the notes + button opens the menu with note, checklist, task, audio and template or creates a new note right away. From the menu, \"Task\" now opens a new task directly.';

  @override
  String get changelog_v2_0_0_bullet_32 =>
      'The app is now also available in English: it follows your phone\'s language, or you can choose it in Settings > Language.';
}
