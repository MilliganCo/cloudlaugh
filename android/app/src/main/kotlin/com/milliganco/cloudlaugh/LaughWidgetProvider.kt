package com.milliganco.cloudlaugh

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.widget.RemoteViews

class LaughWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val ACTION_LAUGH = "com.milliganco.cloudlaugh.LAUGH"

        private val SOUNDS = intArrayOf(
            R.raw.laugh_01, R.raw.laugh_02, R.raw.laugh_03,
            R.raw.laugh_04, R.raw.laugh_05, R.raw.laugh_06,
            R.raw.laugh_07, R.raw.laugh_08, R.raw.laugh_09,
            R.raw.laugh_10, R.raw.laugh_11, R.raw.laugh_12,
            R.raw.laugh_13, R.raw.laugh_14, R.raw.laugh_15,
        )
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (id in appWidgetIds) {
            val views = buildViews(context)
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_LAUGH) {
            val pending = goAsync()
            val resId = SOUNDS.random()
            val player = MediaPlayer.create(context, resId) ?: run {
                pending.finish(); return
            }
            player.setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
            )
            player.setOnCompletionListener {
                it.release()
                pending.finish()
            }
            player.setOnErrorListener { mp, _, _ ->
                mp.release()
                pending.finish()
                true
            }
            player.start()
        }
    }

    private fun buildViews(context: Context): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.laugh_widget)
        val intent = Intent(context, LaughWidgetProvider::class.java).apply {
            action = ACTION_LAUGH
        }
        val pi = PendingIntent.getBroadcast(
            context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        views.setOnClickPendingIntent(R.id.widget_btn, pi)
        return views
    }
}
