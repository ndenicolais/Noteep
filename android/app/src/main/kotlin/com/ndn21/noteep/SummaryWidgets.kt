package com.ndn21.noteep

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.view.View
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

// Rows, title and empty text of each list widget are written by WidgetService
// (lib/utils/widget_service.dart) under "<kind>_rows", "<kind>_title" and
// "<kind>_empty"; the row format is documented in lib/utils/home_widget_rows.dart.
// The string resources are only shown before the first sync.
private const val EXTRA_KIND = "com.ndn21.noteep.SUMMARY_KIND"

/**
 * List widget: a header (icon, title, "+") over a scrolling list of rows.
 * Header tap opens the section (noteep://section/<kind>), "+" an empty
 * editor, a row its item (noteep://open/<note|task|event>/<id>).
 */
abstract class SummaryListWidget(
    private val kind: String,
    private val iconRes: Int,
    private val titleRes: Int,
    private val emptyRes: Int,
    private val newUri: String
) : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = HomeWidgetPlugin.getData(context)
        val title = prefs.getString("${kind}_title", null) ?: context.getString(titleRes)
        val empty = prefs.getString("${kind}_empty", null) ?: context.getString(emptyRes)

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.summary_list_widget)
            views.setImageViewResource(R.id.widget_icon, iconRes)
            views.setTextViewText(R.id.widget_title, title)
            views.setTextViewText(R.id.widget_empty, empty)

            val adapter = Intent(context, SummaryListService::class.java).apply {
                putExtra(EXTRA_KIND, kind)
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                // Unique per widget, so the system doesn't reuse another
                // widget's factory (extras are ignored when comparing intents).
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }
            @Suppress("DEPRECATION")
            views.setRemoteAdapter(R.id.widget_list, adapter)
            views.setEmptyView(R.id.widget_list, R.id.widget_empty)
            views.setPendingIntentTemplate(R.id.widget_list, rowTemplate(context))
            views.setOnClickPendingIntent(
                R.id.widget_header,
                widgetLaunch(context, "noteep://section/$kind")
            )
            views.setOnClickPendingIntent(R.id.widget_add, widgetLaunch(context, newUri))
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
        // Re-reads the rows: new data from the app, or a new day.
        @Suppress("DEPRECATION")
        appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetIds, R.id.widget_list)
    }

    /**
     * Launch intent shared by every row; each row fills in its own data URI,
     * which is only possible while the template has none and is mutable.
     */
    private fun rowTemplate(context: Context): PendingIntent {
        val intent = Intent(context, MainActivity::class.java)
            .setAction(HomeWidgetLaunchIntent.HOME_WIDGET_LAUNCH_ACTION)
        var flags = PendingIntent.FLAG_UPDATE_CURRENT
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            flags = flags or PendingIntent.FLAG_MUTABLE
        }
        return PendingIntent.getActivity(context, 1, intent, flags)
    }
}

class NotesSummaryWidget : SummaryListWidget(
    "notes", R.drawable.ic_widget_note, R.string.widget_notes,
    R.string.widget_notes_empty, NEW_NOTE
)

class TasksSummaryWidget : SummaryListWidget(
    "tasks", R.drawable.ic_widget_task, R.string.widget_tasks,
    R.string.widget_tasks_empty, NEW_TASK
)

class CalendarSummaryWidget : SummaryListWidget(
    "calendar", R.drawable.ic_widget_event, R.string.widget_calendar,
    R.string.widget_calendar_empty, NEW_EVENT
)

class SummaryListService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory =
        SummaryListFactory(applicationContext, intent.getStringExtra(EXTRA_KIND) ?: "notes")
}

private class SummaryListFactory(
    private val context: Context,
    private val kind: String
) : RemoteViewsService.RemoteViewsFactory {

    private var rows: List<JSONObject> = emptyList()

    /** Today/Tomorrow/Yesterday labels by `yyyy-MM-dd` day. */
    private var relativeLabels: Map<String, String> = emptyMap()

    override fun onCreate() {}

    override fun onDataSetChanged() {
        val prefs = HomeWidgetPlugin.getData(context)
        val format = SimpleDateFormat("yyyy-MM-dd", Locale.US)
        fun day(offset: Int): String {
            val cal = Calendar.getInstance()
            cal.add(Calendar.DAY_OF_YEAR, offset)
            return format.format(cal.time)
        }
        val today = day(0)
        relativeLabels = buildMap {
            prefs.getString("label_today", null)?.let { put(today, it) }
            prefs.getString("label_tomorrow", null)?.let { put(day(1), it) }
            prefs.getString("label_yesterday", null)?.let { put(day(-1), it) }
        }

        val array = try {
            JSONArray(prefs.getString("${kind}_rows", null) ?: "[]")
        } catch (e: JSONException) {
            JSONArray()
        }
        val parsed = ArrayList<JSONObject>(array.length())
        for (i in 0 until array.length()) {
            val row = array.optJSONObject(i) ?: continue
            // The calendar only looks ahead: drop the days gone by since the
            // last sync (ISO dates compare as strings).
            val rowDay = row.optString("day", "")
            if (kind == "calendar" && rowDay.isNotEmpty() && rowDay < today) continue
            parsed.add(row)
        }
        rows = parsed
    }

    override fun getCount(): Int = rows.size

    override fun getViewAt(position: Int): RemoteViews {
        val row = rows.getOrNull(position)
            ?: return RemoteViews(context.packageName, R.layout.summary_list_header)
        return if (row.optString("t") == "h") header(row) else item(row)
    }

    private fun header(row: JSONObject): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.summary_list_header)
        val label = relativeLabels[row.optString("day", "")] ?: row.optString("label", "")
        views.setTextViewText(R.id.row_label, label)
        return views
    }

    private fun item(row: JSONObject): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.summary_list_item)
        views.setTextViewText(R.id.row_title, row.optString("title", ""))

        val sub = row.optString("sub", "")
        views.setTextViewText(R.id.row_subtitle, sub)
        views.setViewVisibility(R.id.row_subtitle, if (sub.isEmpty()) View.GONE else View.VISIBLE)

        if (row.has("color")) {
            views.setInt(R.id.row_bar, "setBackgroundColor", row.optLong("color").toInt())
            views.setViewVisibility(R.id.row_bar, View.VISIBLE)
        } else {
            views.setViewVisibility(R.id.row_bar, View.GONE)
        }

        val uri = Uri.Builder()
            .scheme("noteep")
            .authority("open")
            .appendPath(row.optString("kind", ""))
            .appendPath(row.optString("id", ""))
            .build()
        views.setOnClickFillInIntent(R.id.row_root, Intent().setData(uri))
        return views
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 2

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = false

    override fun onDestroy() {}
}
