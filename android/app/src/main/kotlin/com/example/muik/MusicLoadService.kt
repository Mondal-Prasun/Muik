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
            val items:MutableList<MediaItem> = mutableListOf<MediaItem>()
            for(i in audioList){

                   val metaData = MediaMetadata.Builder()
                       .setTitle("Test")
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

    fun shuffleMusic(context: Context, audioList: List<Map<String,String>>, mediaController: MediaController?){

        try{
            mediaController?.clearMediaItems()
            val items:MutableList<MediaItem> = mutableListOf<MediaItem>()
            for(i in audioList){
                    val metaData = MediaMetadata.Builder()
                        .setTitle(i["name"])
//                        .setArtworkData(getAudioThumbnail(context, i["uri"]!!.toUri()),
//                            MediaMetadata.PICTURE_TYPE_FRONT_COVER )
                        .build()
                    val item = MediaItem.Builder()
                        .setUri(i["uri"])
                        .setMediaMetadata(metaData)
                        .build()

                items.add(item)
            }
            mediaController?.shuffleModeEnabled = true
            mediaController?.setMediaItems(items)
            mediaController?.prepare()
            mediaController?.play()

        }catch (e:Exception){
            Log.d("MusicLoadService","Cannot Shuffle music:${e.message}")
        }
    }

    fun toggleShuffleMode(mediaController: MediaController?){
        try{
            if(mediaController?.shuffleModeEnabled == true){
                mediaController.shuffleModeEnabled = false
            }else{
                mediaController?.shuffleModeEnabled = true
            }
        }catch (e:Exception){
            Log.d("MusicLoadService","Cannot toggle Shuffle music:${e.message}")
        }
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

    fun getNextMediaItemMetaData(mediaController: MediaController?, count: Int): List<Map<String,Any?>>{
        try{
            val currentMusicIndex = mediaController!!.currentMediaItemIndex
            val nextMediaItemList = mutableListOf<Map<String, Any?>>();2
            var plusCount:Int = 1
            while(plusCount <= count && mediaController.hasNextMediaItem()){
                val item = mediaController.getMediaItemAt(currentMusicIndex+ plusCount);

                nextMediaItemList.add(mapOf<String, Any?>(
                    "name" to item.mediaMetadata.title.toString(),
                    "artist" to item.mediaMetadata.artist.toString(),
                    "duration" to item.mediaMetadata.durationMs.toString(),
                    "artWork" to item.mediaMetadata.artworkData,
                    "uri" to if (item.requestMetadata.mediaUri == null) "" else item.requestMetadata.mediaUri
                ))
                plusCount++
            }
            return nextMediaItemList;
        }catch (e: Exception){
            Log.d("MusicLoadService, ","Cannot get next music metadata:${e.message}")
            return listOf()
        }
    }



}


