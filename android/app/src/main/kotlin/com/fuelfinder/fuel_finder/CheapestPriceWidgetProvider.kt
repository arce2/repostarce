package com.fuelfinder.fuel_finder

import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Widget de pantalla de inicio con la gasolinera más barata que la app ha
 * visto la última vez (favoritas o resultados de una búsqueda). No hay
 * tareas en segundo plano: los datos se escriben desde Flutter cada vez
 * que la app carga precios en primer plano (ver widget_service.dart).
 */
class CheapestPriceWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.cheapest_price_widget)

            val stationName = widgetData.getString("widget_station_name", null)
            val price = widgetData.getString("widget_price", null)
            val updatedAt = widgetData.getString("widget_updated_at", null)

            if (stationName != null && price != null) {
                views.setTextViewText(R.id.widget_station_name, stationName)
                views.setTextViewText(R.id.widget_price, price)
                views.setTextViewText(R.id.widget_updated, updatedAt ?: "")
            } else {
                views.setTextViewText(R.id.widget_station_name, "Abre Gasly para ver precios")
                views.setTextViewText(R.id.widget_price, "-- €")
                views.setTextViewText(R.id.widget_updated, "")
            }

            val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            views.setOnClickPendingIntent(R.id.widget_title, pendingIntent)
            views.setOnClickPendingIntent(R.id.widget_station_name, pendingIntent)
            views.setOnClickPendingIntent(R.id.widget_price, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
