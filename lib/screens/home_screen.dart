import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:noteep/models/note_model.dart';
import 'package:noteep/screens/note_screen.dart';
import 'package:noteep/services/notes_service.dart';
import 'package:noteep/services/notification_service.dart';
import 'package:noteep/widgets/custom_drawer.dart';
import 'package:noteep/widgets/custom_loader.dart';
import 'package:noteep/widgets/custom_toast.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final NotesService _notesService = NotesService();
  late Stream<List<NoteModel>> _notesStream;
  final Set<NoteModel> _selectedNotes = {};
  late final NotificationService notificationService;

  @override
  void initState() {
    _notesStream = _notesService.notesStream;
    notificationService = NotificationService();
    listenToNotificationStream();
    notificationService.initialize().then((_) {
      checkForNotificationPayload();
    });
    super.initState();
  }

  void listenToNotificationStream() {
    notificationService.behaviorSubject.listen(
      (payload) async {
        if (payload != null) {
          await navigateToNoteScreen(payload);
        }
      },
    );
  }

  void checkForNotificationPayload() async {
    if (notificationService
            .notificationAppLaunchDetails?.didNotificationLaunchApp ??
        false) {
      String? payload = notificationService
          .notificationAppLaunchDetails?.notificationResponse?.payload;
      if (payload != null) {
        await navigateToNoteScreen(payload);
      }
    }
  }

  Future<void> navigateToNoteScreen(String payload) async {
    NoteModel? note = await _notesService.getNoteById(payload);
    if (note != null) {
      Get.to(() => NoteScreen(note: note));
    } else {
      if (mounted) {
        showErrorToast(
          context,
          AppLocalizations.of(context)!.home_screen_payload_error,
        );
      }
    }
  }

  Future<void> deleteSelectedNotes() async {
    for (var note in _selectedNotes) {
      await _notesService.deleteNoteById(note.id);
    }
    setState(() {
      _selectedNotes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).colorScheme.primary,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: PopScope(
        canPop: false,
        child: Scaffold(
          appBar: _buildAppBar(context),
          drawer: const CustomDrawer(),
          backgroundColor: Theme.of(context).colorScheme.primary,
          body: _buildBody(context),
          floatingActionButton: FloatingActionButton(
            foregroundColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            onPressed: () async {
              await Get.to(() => NoteScreen());
            },
            child: Icon(
              MingCuteIcons.mgc_add_fill,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        AppLocalizations.of(context)!.home_screen_title,
        style: GoogleFonts.exo2(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.secondary,
      actions: _selectedNotes.isNotEmpty
          ? [
              IconButton(
                icon: Icon(
                  MingCuteIcons.mgc_delete_line,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: deleteSelectedNotes,
              ),
            ]
          : [],
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<List<NoteModel>>(
      stream: _notesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator(context);
        }

        if (snapshot.hasError) {
          return _buildErrorState(context, snapshot.error);
        }

        var notes = snapshot.data ?? [];
        notes.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

        if (notes.isEmpty) {
          return _buildEmptyState(context);
        }

        return _buildNotesGrid(context, notes);
      },
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Center(
      child: CustomLoader(
        width: 50.w,
        height: 50.h,
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object? error) {
    return Center(
      child: SizedBox(
        width: 320.w,
        child: Text(
          '${AppLocalizations.of(context)!.home_screen_error_state} $error',
          style: GoogleFonts.exo2(
            color: Theme.of(context).colorScheme.tertiary,
            fontSize: 18.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context)!.home_screen_empty_state,
        style: GoogleFonts.exo2(
          color: Theme.of(context).colorScheme.tertiary,
          fontSize: 24.sp,
        ),
      ),
    );
  }

  Widget _buildNotesGrid(BuildContext context, List<NoteModel> notes) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          NoteModel note = notes[index];
          final isSelected = _selectedNotes.contains(note);
          final isNotificationPassed = note.notificationTime != null &&
              note.notificationTime!.isBefore(DateTime.now());
          return GestureDetector(
            onLongPress: () {
              setState(() {
                if (isSelected) {
                  _selectedNotes.remove(note);
                } else {
                  _selectedNotes.add(note);
                }
              });
            },
            onTap: () async {
              if (_selectedNotes.isNotEmpty) {
                setState(() {
                  if (isSelected) {
                    _selectedNotes.remove(note);
                  } else {
                    _selectedNotes.add(note);
                  }
                });
              } else {
                await Get.to(() => NoteScreen(note: note));
              }
            },
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: note.backgroundColor,
                border: Border.all(
                  color: Theme.of(context).colorScheme.tertiary,
                  width: isSelected ? 2.w : 0.5.w,
                ),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    style: GoogleFonts.getFont(
                      note.font,
                      color: note.textColor,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: Text(
                      note.content,
                      style: GoogleFonts.getFont(
                        note.font,
                        color: note.textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 5,
                    ),
                  ),
                  if (note.notificationTime != null) ...[
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          MingCuteIcons.mgc_notification_line,
                          color: note.textColor,
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(
                            note.notificationTime!,
                          ),
                          style: GoogleFonts.exo2(
                            color: note.textColor,
                            fontSize: 14.sp,
                            decoration: isNotificationPassed
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
