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

        val noteCount = widgetData.getInt("note_count", 0)
        val taskCount = widgetData.getInt("task_count", 0)
        val latestNote = widgetData.getString("latest_note", context.getString(R.string.widget_no_notes))

        val views = RemoteViews(context.packageName, R.layout.noteep_widget)
        views.setTextViewText(R.id.widget_note_count, "$noteCount note")
        views.setTextViewText(R.id.widget_task_count, "$taskCount task")
        views.setTextViewText(R.id.widget_latest_note, latestNote ?: context.getString(R.string.widget_no_notes))

        // Tap opens the app
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        if (launchIntent != null) {
            val pendingIntent = android.app.PendingIntent.getActivity(
                context,
                0,
                launchIntent,
                android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(android.R.id.content, pendingIntent)
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
