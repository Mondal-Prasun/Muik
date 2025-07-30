package com.example.muik


import android.app.Notification
import android.app.PendingIntent
import android.app.Service
import android.content.ComponentName
import android.content.ContentResolver
import android.content.ContentUris
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.MediaMetadataRetriever
import android.media.MediaPlayer
import android.media.ThumbnailUtils
import android.net.Uri
import android.os.Binder
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.os.IBinder
import android.provider.MediaStore
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat
import androidx.media3.common.MediaItem
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.session.MediaController
import androidx.media3.session.MediaSession
import androidx.media3.session.MediaSessionService
import androidx.media3.session.SessionToken
import androidx.media3.session.legacy.MediaSessionCompat
import com.google.common.util.concurrent.ListenableFuture
import com.google.common.util.concurrent.MoreExecutors
import java.io.IOException
import kotlin.contracts.contract


data class AudioInfo(
    val id : Long,
    val uri :Uri,
    val name :String,
    val duration:Int,
    val absolutePath : String,
    )


class MusicLoadService(context: Context){



//   fun loadMusicFromStorage(context:Context,storagePath : String): MutableList<AudioInfo>{
//        val audioList = mutableListOf<AudioInfo>()
//        val folderPath = "/storage/emulated/0/Music/The Witcher 3"
//        val audioUri = if(VERSION.SDK_INT >= VERSION_CODES.Q){
//            MediaStore.Audio.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
//        }else{
//                   MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
//        }
//
//       val projection = arrayOf(
//           MediaStore.Audio.Media._ID,
//           MediaStore.Audio.Media.DISPLAY_NAME,
//           MediaStore.Audio.Media.DURATION,
//           MediaStore.Audio.Media.DATA,
//       )
//       val selection = "${MediaStore.Audio.Media.DATA} LIKE ?"
//
//       val selectionArgs = arrayOf(
//           "$folderPath/%",
//       )
//
//       val sortOrder = "${MediaStore.Audio.Media.DISPLAY_NAME} ASC"
//
//       val query = context.contentResolver.query(
//           audioUri,
//           projection,
//           selection,
//           selectionArgs,
//           sortOrder
//       )
//
//
//       query?.use { cursor ->
//           val columnId = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
//           val columName = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DISPLAY_NAME)
//           val columnDuration = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
//          val columnData = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA)
//
//           while(cursor.moveToNext()){
//               val id = cursor.getLong(columnId)
//               val name = cursor.getString(columName)
//               val duration = cursor.getInt(columnDuration)
//               val data = cursor.getString(columnData)
//               val contentUri= ContentUris.withAppendedId(audioUri,id)
//
//
//
//               audioList.add(AudioInfo(
//                   id,contentUri,name,duration, data,
//               ))
//
//           }
//       }
//
//       query?.close()
//         return  audioList
//    }

     fun getAudioThumbnail(context: Context,aUri : Uri) :ByteArray?{
        val retriver = MediaMetadataRetriever()
        try{
            retriver.setDataSource(context,aUri)
            val thumbNail = retriver.embeddedPicture
            return if(thumbNail == null || thumbNail.isEmpty()){
                null
            }else{
                thumbNail
            }
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

    fun playSingleAudio(uriString: String, mediaController: MediaController?){
        try{
                val item:MediaItem = MediaItem.fromUri(uriString)
                mediaController?.setMediaItem(item)
                mediaController?.prepare()
                mediaController?.play()
        }catch (e:Exception){
            Log.d("MusicLoadService","Cannot play music:${e.message}")
        }
    }

    fun playListAudio(audioList : List<String>, mediaController: MediaController?){
        try{
            val items:MutableList<MediaItem> = mutableListOf<MediaItem>()
            audioList.forEach { it->
                items.add(MediaItem.fromUri(it))
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


}


