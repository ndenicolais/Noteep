package com.ndn21.noteep

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent

// URIs parsed by HomeWidgetAction (lib/core/routing/home_widget_action.dart),
// which opens the matching empty editor.
private const val NEW_NOTE = "noteep://new/note"
private const val NEW_TASK = "noteep://new/task"
private const val NEW_EVENT = "noteep://new/event"

// Distinct data URIs keep the PendingIntents apart even with the same
// request code that HomeWidgetLaunchIntent always uses.
private fun launch(context: Context, uri: String): PendingIntent =
    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse(uri))

/** "Quick actions" widget: new note, new task and new event side by side. */
class QuickActionsWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val views = RemoteViews(context.packageName, R.layout.quick_actions_widget)
        views.setOnClickPendingIntent(R.id.widget_action_note, launch(context, NEW_NOTE))
        views.setOnClickPendingIntent(R.id.widget_action_task, launch(context, NEW_TASK))
        views.setOnClickPendingIntent(R.id.widget_action_event, launch(context, NEW_EVENT))
        appWidgetManager.updateAppWidget(appWidgetIds, views)
    }
}

/** 1x1 widget that opens a single empty editor when tapped. */
abstract class QuickActionButtonWidget(
    private val layoutId: Int,
    private val uri: String
) : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val views = RemoteViews(context.packageName, layoutId)
        views.setOnClickPendingIntent(R.id.widget_root, launch(context, uri))
        appWidgetManager.updateAppWidget(appWidgetIds, views)
    }
}

class NewNoteWidget : QuickActionButtonWidget(R.layout.new_note_widget, NEW_NOTE)

class NewTaskWidget : QuickActionButtonWidget(R.layout.new_task_widget, NEW_TASK)

class NewEventWidget : QuickActionButtonWidget(R.layout.new_event_widget, NEW_EVENT)
