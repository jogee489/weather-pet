package com.example.weather_pet

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Home screen widget for Weather Pet.
 *
 * Data is written by the Flutter side via the `home_widget` package into
 * SharedPreferences under the app's default preferences file. This provider
 * reads those values and updates the RemoteViews each time the OS triggers an
 * update or the Flutter app calls HomeWidget.updateWidget().
 */
class WeatherPetWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            // Read data saved by home_widget (Flutter side)
            val widgetData = HomeWidgetPlugin.getData(context)

            val temperature = widgetData.getString("temperature", "--°C") ?: "--°C"
            val city       = widgetData.getString("city", "") ?: ""
            val condition  = widgetData.getString("condition", "Loading…") ?: "Loading…"
            val emoji      = widgetData.getString("emoji", "🐱") ?: "🐱"

            val views = RemoteViews(context.packageName, R.layout.weather_pet_widget)
            views.setTextViewText(R.id.widget_emoji, emoji)
            views.setTextViewText(R.id.widget_temperature, temperature)
            views.setTextViewText(R.id.widget_condition, condition)
            views.setTextViewText(R.id.widget_city, city)

            // Tap widget → open app at home screen
            val launchIntent = context.packageManager
                .getLaunchIntentForPackage(context.packageName)
                ?.apply {
                    data = Uri.parse("weatherpet://home")
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }

            if (launchIntent != null) {
                val pendingIntent = android.app.PendingIntent.getActivity(
                    context,
                    appWidgetId,
                    launchIntent,
                    android.app.PendingIntent.FLAG_UPDATE_CURRENT or
                            android.app.PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(android.R.id.background, pendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
