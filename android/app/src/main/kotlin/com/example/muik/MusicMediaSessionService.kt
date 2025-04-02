package com.example.muik

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.TaskStackBuilder
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.session.MediaSession
import androidx.media3.session.MediaSessionService
import com.google.common.util.concurrent.ListenableFuture


class MusicMediaSessionService :MediaSessionService() {
    
    private var _mediaSession:MediaSession? = null
    private val mediaSession get() = _mediaSession!!

    companion object{
        private const val NOTIFICATION_ID = 69
        private const val CHANNEL_ID = "Channel_69"
        private val immutableFlag = if(VERSION.SDK_INT >= VERSION_CODES.O) PendingIntent.FLAG_IMMUTABLE else 0
    }


    @UnstableApi
    override fun onCreate() {
        super.onCreate()

        val player = ExoPlayer.Builder(this).build()
        _mediaSession = MediaSession.Builder(this,player)
            .build()
        setListener(MusicSessionServiceLister())
    }
    
    override fun onGetSession(controllerInfo: MediaSession.ControllerInfo): MediaSession? {
        return mediaSession
    }


    override fun onTaskRemoved(rootIntent: Intent?) {
        val player = mediaSession.player
        if(!player.playWhenReady || player.mediaItemCount == 0){
            stopSelf()
        }
    }


    @UnstableApi
    override fun onDestroy() {
        _mediaSession?.run {
            getBackStandActivity()?.let {
                setSessionActivity(it)
            }
            player.release()
            release()
            _mediaSession = null
        }
        super.onDestroy()
    }

    private fun getSingleTopActivity() :PendingIntent?{
        return PendingIntent.getBroadcast(
            this,
            0,
            Intent(this,MainActivity::class.java),
            immutableFlag or PendingIntent.FLAG_UPDATE_CURRENT
        )
    }

    private fun getBackStandActivity():PendingIntent?{
        return TaskStackBuilder.create(this).run {
            addNextIntent(Intent(this@MusicMediaSessionService,MainActivity::class.java))
            getPendingIntent(0, immutableFlag or PendingIntent.FLAG_UPDATE_CURRENT)
        }
    }

    @UnstableApi
    private inner class MusicSessionServiceLister : Listener{
        override fun onForegroundServiceStartNotAllowedException() {
            if (ActivityCompat.checkSelfPermission(
                    this@MusicMediaSessionService,
                    Manifest.permission.POST_NOTIFICATIONS
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                return
            }
              val notificationManagerCompat:NotificationManagerCompat =
                   NotificationManagerCompat.from(this@MusicMediaSessionService)
              ensureNotificationChannel(notificationManagerCompat)

            val builder = NotificationCompat.Builder(this@MusicMediaSessionService, CHANNEL_ID)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setStyle(
                    NotificationCompat.BigTextStyle().bigText("Test case")
                )
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setOnlyAlertOnce(true)
                .also { builder ->
                    getBackStandActivity()?.let { builder.setContentIntent(it) }
                }
                .build()

            notificationManagerCompat.notify(NOTIFICATION_ID,builder)
        }


        private fun ensureNotificationChannel(notificationManagerCompat: NotificationManagerCompat){
             if (VERSION.SDK_INT >= VERSION_CODES.O){
                 val channel = NotificationChannel(
                     CHANNEL_ID,
                     "Foreground channel",
                     NotificationManager.IMPORTANCE_DEFAULT
                 )

                 notificationManagerCompat.createNotificationChannel(
                     channel
                 )

             }
        }


    }

}