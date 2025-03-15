import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:noteep/models/note_model.dart';
import 'package:noteep/services/notes_service.dart';
import 'package:noteep/services/notification_service.dart';
import 'package:noteep/theme/app_colors.dart';
import 'package:noteep/utils/permission_helper.dart';
import 'package:noteep/widgets/custom_color_picker.dart';
import 'package:noteep/widgets/custom_font_picker.dart';
import 'package:noteep/widgets/custom_toast.dart';

class NoteScreen extends StatefulWidget {
  final NoteModel? note;

  const NoteScreen({super.key, this.note});

  @override
  NoteScreenState createState() => NoteScreenState();
}

class NoteScreenState extends State<NoteScreen> {
  final NotesService _notesService = NotesService();
  final NotificationService _notificationService = NotificationService();
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _content;
  late Color _backgroundColor;
  late Color _textColor;
  late String _font;
  late List<String> _attachments;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _title = widget.note!.title;
      _content = widget.note!.content;
      _backgroundColor = widget.note!.backgroundColor;
      _textColor = widget.note!.textColor;
      _font = widget.note!.font;
      _attachments = widget.note!.attachments;
      if (widget.note!.notificationTime != null) {
        _selectedDate = widget.note!.notificationTime;
        _selectedTime = TimeOfDay.fromDateTime(widget.note!.notificationTime!);
      }
    } else {
      _title = '';
      _content = '';
      _backgroundColor = Color(0xFFFBF8CC);
      _textColor = Color(0xFF000000);
      _font = 'Exo 2';
      _attachments = [];
    }
    _notificationService.initialize();
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      DateTime? notificationTime;
      if (_selectedDate != null && _selectedTime != null) {
        notificationTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );

        if (notificationTime.isBefore(DateTime.now())) {
          if (widget.note != null &&
              widget.note!.notificationTime != null &&
              widget.note!.notificationTime!.isBefore(DateTime.now())) {
            notificationTime = null;
          } else {
            showErrorToast(
              context,
              AppLocalizations.of(context)!.note_screen_notification_time_error,
            );
            return;
          }
        }
      }

      NoteModel note = NoteModel(
        id: widget.note?.id ?? '',
        title: _title,
        content: _content,
        backgroundColor: _backgroundColor,
        textColor: _textColor,
        font: _font,
        attachments: _attachments,
        notificationTime: notificationTime,
      );

      if (widget.note == null) {
        await _notesService.addNote(note);
      } else {
        await _notesService.updateNote(note);
      }

      if (notificationTime != null) {
        _notificationService.scheduleNotification(
          note.id.hashCode,
          notificationTime,
          note.title,
          note.content,
          note.id,
        );
      }

      Get.back();
    }
  }

  void _removeNotification() {
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
    });
    _notificationService.cancelNotification(widget.note?.id.hashCode ?? 0);
  }

  Future<void> _showColorPicker({required bool isBackgroundColor}) async {
    Color? selectedColor = await showModalBottomSheet<Color>(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.0),
        height: 100,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                isBackgroundColor
                    ? AppLocalizations.of(context)!
                        .note_screen_custom_background
                    : AppLocalizations.of(context)!.note_screen_custom_text,
                style: GoogleFonts.exo2(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: CustomBlockPicker(
                pickerColor: isBackgroundColor ? _backgroundColor : _textColor,
                availableColors:
                    isBackgroundColor ? notesBackgroundColors : notesTextColors,
                onColorChanged: (color) {
                  Get.back(result: color);
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: _backgroundColor,
    );
    if (selectedColor != null) {
      setState(() {
        if (isBackgroundColor) {
          _backgroundColor = selectedColor;
        } else {
          _textColor = selectedColor;
        }
      });
    }
  }

  Future<void> _showFontPicker() async {
    String? selectedFont = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.0),
        height: 100,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context)!.note_screen_custom_font,
                style: GoogleFonts.exo2(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: CustomFontPicker(
                pickerFont: _font,
                availableFonts: [
                  'Exo 2',
                  'Montserrat',
                  'Oswald',
                  'Raleway',
                  'Pacifico',
                ],
                onFontChanged: (font) {
                  Get.back(result: font);
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: _backgroundColor,
    );
    if (selectedFont != null) {
      setState(() {
        _font = selectedFont;
      });
    }
  }

  void _showNotificationPanel(BuildContext context) async {
    try {
      await requestNotificationPermission(context, () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(
                    MingCuteIcons.mgc_notification_line,
                    color: AppColors.baseDark,
                  ),
                  title: Text(
                    _selectedDate != null && _selectedTime != null
                        ? AppLocalizations.of(context)!
                            .note_screen_notification_edit
                        : AppLocalizations.of(context)!
                            .note_screen_notification_add,
                    style: GoogleFonts.exo2(
                      color: AppColors.baseDark,
                    ),
                  ),
                  onTap: _showDateTimePicker,
                ),
                if (_selectedDate != null && _selectedTime != null)
                  ListTile(
                    leading: Icon(
                      MingCuteIcons.mgc_notification_off_line,
                      color: AppColors.baseDark,
                    ),
                    title: Text(
                      AppLocalizations.of(context)!
                          .note_screen_notification_remove,
                      style: GoogleFonts.exo2(
                        color: AppColors.baseDark,
                      ),
                    ),
                    onTap: () {
                      _removeNotification();
                      Get.back();
                    },
                  ),
              ],
            );
          },
          backgroundColor: _backgroundColor,
        );
      });
    } catch (e) {
      if (context.mounted) {
        showErrorToast(
          context,
          AppLocalizations.of(context)!.note_screen_notification_general_error,
        );
      }
    }
  }

  Future<void> _showDateTimePicker() async {
    DateTime firstDate = DateTime.now();
    DateTime initialDate = _selectedDate ?? firstDate;

    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      if (mounted) {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: _selectedTime ?? TimeOfDay.now(),
          initialEntryMode: TimePickerEntryMode.input,
        );

        if (pickedTime != null) {
          setState(() {
            _selectedDate = pickedDate;
            _selectedTime = pickedTime;
            Get.back();
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: _backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              MingCuteIcons.mgc_arrow_left_line,
              color: AppColors.baseDark,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          title: Text(
            widget.note == null
                ? AppLocalizations.of(context)!.note_screen_title_add
                : AppLocalizations.of(context)!.note_screen_title_edit,
            style: GoogleFonts.exo2(
              color: AppColors.baseDark,
            ),
          ),
          centerTitle: true,
          backgroundColor: _backgroundColor,
          foregroundColor: AppColors.baseDark,
          actions: [
            IconButton(
              icon: Icon(
                MingCuteIcons.mgc_save_2_line,
                color: AppColors.baseDark,
              ),
              onPressed: _saveNote,
            ),
          ],
        ),
        backgroundColor: _backgroundColor,
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: _title,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)!.note_screen_note_title,
                    labelStyle: GoogleFonts.exo2(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 22.sp,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  onSaved: (value) => _title = value!,
                  validator: (value) => value!.isEmpty
                      ? AppLocalizations.of(context)!
                          .note_screen_note_title_error
                      : null,
                  style: GoogleFonts.getFont(
                    _font,
                    color: _textColor,
                  ),
                  maxLength: 40,
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: _content,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!
                          .note_screen_note_content,
                      labelStyle: GoogleFonts.exo2(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 22.sp,
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      alignLabelWithHint: true,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    onSaved: (value) => _content = value!,
                    validator: (value) => value!.isEmpty
                        ? AppLocalizations.of(context)!
                            .note_screen_note_content_error
                        : null,
                    style: GoogleFonts.getFont(
                      _font,
                      color: _textColor,
                    ),
                    maxLines: null,
                    expands: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 8.0,
          color: _backgroundColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  MingCuteIcons.mgc_palette_line,
                  color: AppColors.baseDark,
                ),
                onPressed: () => _showColorPicker(isBackgroundColor: true),
              ),
              IconButton(
                icon: Icon(
                  MingCuteIcons.mgc_text_color_line,
                  color: AppColors.baseDark,
                ),
                onPressed: () => _showColorPicker(isBackgroundColor: false),
              ),
              IconButton(
                icon: Icon(
                  MingCuteIcons.mgc_font_line,
                  color: AppColors.baseDark,
                ),
                onPressed: _showFontPicker,
              ),
              IconButton(
                icon: Icon(
                  MingCuteIcons.mgc_notification_line,
                  color: AppColors.baseDark,
                ),
                onPressed: () => _showNotificationPanel(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
