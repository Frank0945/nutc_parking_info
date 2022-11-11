package com.nutc_parking_info

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class HomeWidgetExampleProvider : HomeWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {

        fun isNumeric(s: String): Boolean {
            return try {
                s.toDouble()
                true
            } catch (e: NumberFormatException) {
                false
            }
        }

        fun getTextColor(percent: Float): String {
            if (percent < 0.3)
                return "#741b47"
    
            if (percent < 0.5)
                return "#bf9000"
    
            return "#38761d"
        }

        fun getBarWidth(i: Int, percent: Float): Float {
            if (percent < 0.3 && i == 2)
                return -1f
    
            if (percent < 0.5 && i == 1)
                return -1f

            if (percent >= 0.5 && i == 0)
                return -1f
    
            return 0f
        }

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.example_layout).apply {
                // Open App on Widget Click
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)

                val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                        context,
                        Uri.parse("homeWidgetExample://refreshclicked")
                )
                setOnClickPendingIntent(R.id.refresh, backgroundIntent)

                /* ----- */


                val ids_1 = arrayOf(R.id.amount1, R.id.amount2, R.id.amount3)
                val ids_2 = arrayOf(arrayOf(R.id.progress1_1, R.id.progress1_2, R.id.progress1_3), arrayOf(R.id.progress2_1, R.id.progress2_2, R.id.progress2_3), arrayOf(R.id.progress3_1, R.id.progress3_2, R.id.progress3_3))
                val ids_3 = arrayOf(R.id.name1, R.id.name2, R.id.name3)

                for(i in 1..3) {
                            
                    val progress = widgetData.getInt("progress" + i, 0)
                    setTextViewText(ids_1[i - 1], progress.toString())                    

                    val max = widgetData.getInt("max" + i, 0)

                    val percent = progress.toFloat() / kotlin.math.max(max, 1)

                    for(i2 in 0..2){
                        setInt(ids_2[i - 1][i2], "setMax", max)
                        setInt(ids_2[i - 1][i2], "setProgress", progress)

                        setViewLayoutWidth(ids_2[i - 1][i2], getBarWidth(i2, percent), 0)
                    }
                    
                    setTextColor(ids_1[i - 1], android.graphics.Color.parseColor(getTextColor(percent)))
                    setTextColor(ids_3[i - 1], android.graphics.Color.parseColor(getTextColor(percent)))

                }

                val refresh = widgetData.getString("refresh", "⟳")
                setTextViewText(R.id.refresh, refresh)
                              
                var updateTime: String = widgetData.getString("updateTime", "--").toString()

                if (isNumeric(updateTime.substring(0, 2))) {
                    var h: Int = updateTime.substring(0, 2).toInt()
                    var hName: String = "上午 "

                    if (h > 12) {
                        hName = "下午 "
                        h -= 12
                        if (h < 10) {
                            updateTime = "0" + h + updateTime.drop(2) 
                        } else {
                            updateTime = h.toString() + updateTime.drop(2) 
                        }
                    } else if (h == 0) {
                        updateTime = "12" + updateTime.drop(2) 
                    }
                    setTextViewText(R.id.updateTimeLabel, hName)
                    setTextViewText(R.id.updateTime, updateTime)
                }
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}