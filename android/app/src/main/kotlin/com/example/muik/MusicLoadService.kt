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


class MusicLoadService{

    private var kJob: Job? = null

    fun getAudioThumbnail(context: Context,aUri : Uri) :ByteArray?{
        val retriver = MediaMetadataRetriever()
        var thumbnail: ByteArray? = null
        try{
            retriver.setDataSource(context,aUri)
            thumbnail = retriver.embeddedPicture
            return thumbnail
        }catch ( e:Exception){
            Log.d("MediaService","Cannot get embaded thumbnail : ${e.message}")
            return  null
        }catch (e : IllegalStateException){
            Log.d("MediaService", "Cannot get audio thumbnail :${e.message}")
            return null
        }finally {
            retriver.release()
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



}


