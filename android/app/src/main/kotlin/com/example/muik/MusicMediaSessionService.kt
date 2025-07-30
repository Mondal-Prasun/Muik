package com.example.muik


import android.app.PendingIntent
import android.app.TaskStackBuilder

import android.content.Intent

import android.os.Build.VERSION
import android.os.Build.VERSION_CODES

import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.session.MediaSession
import androidx.media3.session.MediaSessionService



class MusicMediaSessionService :MediaSessionService() {
    
    private var _mediaSession:MediaSession? = null
    private val mediaSession get() = _mediaSession!!

    companion object{
        private val immutableFlag = if(VERSION.SDK_INT >= VERSION_CODES.O) PendingIntent.FLAG_IMMUTABLE else 0
    }


    @UnstableApi
    override fun onCreate() {
        super.onCreate()

        val player = ExoPlayer.Builder(this).build()
        _mediaSession = MediaSession.Builder(this,player)
            .build()

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


    private fun getBackStandActivity():PendingIntent?{
        return TaskStackBuilder.create(this).run {
            addNextIntent(Intent(this@MusicMediaSessionService,MainActivity::class.java))
            getPendingIntent(0, immutableFlag or PendingIntent.FLAG_UPDATE_CURRENT)
        }
    }



}