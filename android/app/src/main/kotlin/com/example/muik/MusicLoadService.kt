package com.example.muik



import android.content.Context
import android.media.MediaMetadataRetriever

import android.net.Uri
import android.util.Log
import androidx.media3.common.MediaItem
import androidx.media3.common.MediaMetadata
import androidx.media3.session.MediaController



class MusicLoadService{



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

    fun shuffleMusic(audioList: List<Map<String,String>>, mediaController: MediaController?){

        try{
            val items:MutableList<MediaItem> = mutableListOf<MediaItem>()
            for(i in audioList){
                    val metaData = MediaMetadata.Builder()
                        .setTitle(i["name"])
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

}


