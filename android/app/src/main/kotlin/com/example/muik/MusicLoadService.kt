package com.example.muik



import android.content.Context
import android.media.MediaMetadataRetriever

import android.net.Uri
import android.util.Log
import androidx.core.net.toUri
import androidx.media3.common.MediaItem
import androidx.media3.common.MediaMetadata
import androidx.media3.common.Player
import androidx.media3.session.MediaController
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import java.util.Objects


class MusicLoadService{

    private var kJob: Job? = null

    fun getAudioThumbnail(mediaController: MediaController?) :ByteArray?{
        try{
            return mediaController?.mediaMetadata?.artworkData
        }catch (e: Exception){
            Log.d("MusicLoadService","Cannot retrive music thumbnail")
            return null
        }
    }

    fun playSingleAudio(context: Context, uriString: String, mediaController: MediaController?){
        try{

                val item:MediaItem = MediaItem.fromUri(uriString)
                mediaController?.setMediaItem(item)
                mediaController?.prepare()
                mediaController?.play()
        }catch (e:Exception){
            Log.d("MusicLoadService","Cannot play music:${e.message}")
        }
    }

    fun playListAudio(audioList : List<Map<String,String>>, mediaController: MediaController?){

        try{
            mediaController?.clearMediaItems()
            val items:MutableList<MediaItem> = mutableListOf<MediaItem>()
            for(i in audioList){

                   val metaData = MediaMetadata.Builder()
                       .setTitle(i["name"])
                       .setArtist(i["artist"])
                       .build()
                  val  item = MediaItem.Builder()
                       .setUri(i["uri"])
                       .setMediaMetadata(metaData)
                       .build()

                items.add(item)
            }
            if(mediaController?.shuffleModeEnabled == true){
                mediaController.shuffleModeEnabled = false
            }
            mediaController?.setMediaItems(items)
            mediaController?.prepare()
            mediaController?.play()

        }catch (e:Exception){
            Log.d("MusicLoadService","Cannot pause music:${e.message}")
        }
    }

    fun getCurrentAudioMediaIndex(mediaController: MediaController?):Int?{
        return mediaController?.currentMediaItemIndex
    }

    fun addNextAudioMediaItem(mediaController: MediaController?, nextAudio :Map<String,String>, setIndex: Int){
            try {
                val metaData = MediaMetadata.Builder()
                    .setTitle(nextAudio["name"])
                    .setArtist(nextAudio["artist"])
                    .build()
                val  item = MediaItem.Builder()
                    .setUri(nextAudio["uri"])
                    .setMediaMetadata(metaData)
                    .build()
                mediaController?.addMediaItem(setIndex, item)

            }catch(e: Exception) {
                Log.d("MusicLoadService", "Cannot set next Music:${e.message}")
            }
    }

    fun removeAudioMediaItem(mediaController: MediaController?, removeIndex:Int){
        try{
            Log.d("MusicLoadService", "Removed index: $removeIndex..............")
            mediaController?.removeMediaItem(removeIndex)
        }catch (e: Exception){
            Log.d("MusicLoadService", "Cannot remove music from list:${e.message}")
        }
    }

    fun pauseAudio(mediaController: MediaController?){
        try{
            if(mediaController!!.isPlaying){
                mediaController.pause()
            }
        }catch (e:Exception){
            Log.d("MusicLoadService","Cannot pause music:${e.message}")
        }
    }


    fun resumeAudio(mediaController: MediaController?){
        try{
            if(!mediaController!!.isPlaying){
                mediaController.play()
            }
        }catch (e:Exception){
            Log.d("MusicLoadService","Cannot resume music:${e.message}")
        }
    }


    fun isMusicPlaying(mediaController: MediaController?): Boolean{
        return mediaController!!.isPlaying
    }


    fun nextAudio(mediaController: MediaController?): Boolean{
        try{
            mediaController?.seekToNext()
            return true
        }catch(e: Exception){
            Log.d("MusicLoadService","Cannot change to next music music:${e.message}")
            return false
        }
    }

    fun prevAudio(mediaController: MediaController?) : Boolean{
        try{
            mediaController?.seekToPrevious()
            return true
        }catch(e: Exception){
            Log.d("MusicLoadService","Cannot change to prev music music:${e.message}")
            return false
        }
    }


}


