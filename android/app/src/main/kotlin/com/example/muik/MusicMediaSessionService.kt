package com.example.muik


import android.app.PendingIntent
import android.app.TaskStackBuilder

import android.content.Intent

import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import androidx.media3.common.Player

import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.session.MediaSession
import androidx.media3.session.MediaSessionService



class MusicMediaSessionService:MediaSessionService(){
    
    private var _mediaSession:MediaSession? = null
    private var _player:ExoPlayer? = null
    private val mediaSession get() = _mediaSession!!

    companion object{
        private const val immutableFlag = PendingIntent.FLAG_IMMUTABLE
    }


    @UnstableApi
    override fun onCreate() {
        super.onCreate()

        _player = ExoPlayer.Builder(this).build()
        _mediaSession = MediaSession.Builder(this,_player!!)
            .build()

        _player!!.addListener(object : Player.Listener{
            override fun onIsPlayingChanged(isPlaying: Boolean) {

                super.onIsPlayingChanged(isPlaying)
            }
        })
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