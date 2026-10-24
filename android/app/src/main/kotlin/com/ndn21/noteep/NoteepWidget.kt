package com.ndn21.noteep

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class NoteepWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)

        // Ready-to-show labels in the app language, written by WidgetService;
        // the string resources are only shown before the first sync.
        val noteCount = widgetData.getString("note_count", null)
            ?: context.getString(R.string.widget_note_count_empty)
        val taskCount = widgetData.getString("task_count", null)
            ?: context.getString(R.string.widget_task_count_empty)
        val latestNote = widgetData.getString("latest_note", null)
            ?: context.getString(R.string.widget_no_notes)

        val views = RemoteViews(context.packageName, R.layout.noteep_widget)
        views.setTextViewText(R.id.widget_note_count, noteCount)
        views.setTextViewText(R.id.widget_task_count, taskCount)
        views.setTextViewText(R.id.widget_latest_note, latestNote)

        // Tap opens the app
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        if (launchIntent != null) {
            val pendingIntent = android.app.PendingIntent.getActivity(
                context,
                0,
                launchIntent,
                android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
