package com.example.muik

import android.Manifest
import android.app.Activity
import android.app.ComponentCaller


import android.content.ComponentName
import android.content.Intent

import io.flutter.embedding.android.FlutterActivity

//This is libraries to get native apis

import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.os.Looper
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.net.toUri
import androidx.media3.common.MediaMetadata
import androidx.media3.common.Player
import androidx.media3.session.MediaController

import androidx.media3.session.SessionToken
import io.flutter.embedding.engine.FlutterEngine

import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.net.URI


class MainActivity : FlutterActivity(){
    companion object{
        private const val DART_CHANNEL = "Android_Channel_Music"
        private const val FLUTTER_CHANNEL_FOR_PLAY = "Flutter_Channel_Music/Play"
        private const val FLUTTER_CHANNEL_FOR_META = "Flutter_Channel_Music/Meta"
        private const val FLUTTER_CHANNEL_FOR_DU = "Flutter_Channel_Music/Du"

        private const val READ_MUSIC_REQUEST_CODE = 101
        private const val REQUEST_CODE_OPEN_DIRECTORY = 42
        private var mediaSessionController:MediaController?= null
    }

    private var resultPending:MethodChannel.Result? = null
    private val musicLoadService : MusicLoadService = MusicLoadService()
    private val folderLoad:FolderLoad = FolderLoad()

    private var flEngine : FlutterEngine? = null

    private var kJob : Job? = null



    override fun onStart() {
        super.onStart()
        val sessionToken = SessionToken(context.applicationContext,
            ComponentName(context.applicationContext,MusicMediaSessionService::class.java)
        )
        val factory = MediaController.Builder(context.applicationContext,sessionToken).buildAsync()
        factory.addListener(
            {
                mediaSessionController = factory.get()
            },
            ContextCompat.getMainExecutor(this@MainActivity)
        )

        val flChannelPlay = MethodChannel(flEngine!!.dartExecutor.binaryMessenger, FLUTTER_CHANNEL_FOR_PLAY)
        val flChannelMeta = MethodChannel(flEngine!!.dartExecutor.binaryMessenger, FLUTTER_CHANNEL_FOR_META)
        val flChannelDu = MethodChannel(flEngine!!.dartExecutor.binaryMessenger, FLUTTER_CHANNEL_FOR_DU)

        mediaSessionController?.addListener(object : Player.Listener{
            override fun onIsPlayingChanged(isPlaying: Boolean) {
                flChannelPlay.invokeMethod("IsKtMusicPlaying",isPlaying)
                kJob?.cancel()
                kJob = CoroutineScope(Dispatchers.Main).launch {
                    while(isActive) {
                        Log.d(
                            "Music",
                            "currentPosition: ${mediaSessionController!!.currentPosition}"
                        )
                        flChannelDu.invokeMethod("GetCurrentDuPos", mediaSessionController!!.currentPosition.toString())
                        delay(1000)
                    }
                }
                if(!isPlaying){
                    kJob?.cancel("Not Playing the music")
                }
            }

            override fun onIsLoadingChanged(isLoading: Boolean) {
                Log.d("Music","has loaded: $isLoading .........................................................................................")
               if(!isLoading){
                   flChannelMeta.invokeMethod("MediaChanged", mapOf<String,String>(
                       "name" to mediaSessionController!!.mediaMetadata.title.toString(),
                       "artist" to mediaSessionController!!.mediaMetadata.artist.toString(),
                       "duration" to mediaSessionController!!.duration.toString()
                   ))
               }
            }

            override fun onMediaMetadataChanged(mediaMetadata: MediaMetadata) {
//                 flChannelMeta.invokeMethod("MediaChanged", mapOf<String,String>(
//                     "name" to mediaSessionController!!.mediaMetadata.title.toString(),
//                     "artist" to mediaSessionController!!.mediaMetadata.artist.toString(),
//                     "duration" to mediaSessionController!!.duration.toString()
//                     ))
            }

            override fun onEvents(player: Player, events: Player.Events) {

            }
        })
    }



    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        //requesting media storage permission
         requestAudioStoragePermission()
        flEngine = flutterEngine

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DART_CHANNEL
        ).setMethodCallHandler { call, result ->

            when(call.method){
                "pickPreferredDirectory" ->{
                       openDirectoryPicker(result)
                }

                "loadMusicFromStorage" ->{
                      val subDirUriString:String = call.arguments<String>() as String

                        val subDirUri = subDirUriString.toUri()
                         try{
                             kJob?.cancel()
                             kJob = CoroutineScope(Dispatchers.IO).launch {
                                 val allContent = folderLoad.loadContentFromDirectories(applicationContext, subDirUri)
                                 withContext(Dispatchers.Main) {
                                     result.success(allContent)
                                 }
                                 this.cancel()
                             }
                         }catch (e:Exception){
                             result.error("ERROR URI","Sub dir string is null : ${e.message}",null)
                         }
                }

                "startSingleMusic" ->{
                    val sUri:String? = call.arguments<String>()
                    if(sUri!= null) {
                        musicLoadService.playSingleAudio(context,sUri, mediaSessionController)
                    }
                }

                "startMusicList" ->{
                    val audioUriStrings = call.arguments<List<Map<String,String>>>() as List<Map<String,String>>
                    if(audioUriStrings.isNotEmpty()){
                        musicLoadService.playListAudio(audioUriStrings, mediaSessionController)
                    }
                }

                "pauseMusic" ->{
                     musicLoadService.pauseAudio(mediaSessionController)
                }
                "resumeMusic" ->{
                    musicLoadService.resumeAudio(mediaSessionController)
                }
                "isMusicPlaying" ->{
                    val isPlaying = musicLoadService.isMusicPlaying(mediaSessionController)
                    result.success(isPlaying)
                }
                "shuffleMusic" ->{
                    val audioUriStrings = call.arguments<List<Map<String,String>>>() as List<Map<String,String>>
                    if(audioUriStrings.isNotEmpty()){
                        musicLoadService.shuffleMusic(context,audioUriStrings, mediaSessionController)
                    }
                }
                "toggleShuffleMode" ->{
                   musicLoadService.toggleShuffleMode(mediaSessionController)
                }
                "getAudioArt" ->{
                    val art = mediaSessionController!!.mediaMetadata.artworkData
                    result.success(art)
                }
                "nextMusic" ->{
                    val res = musicLoadService.nextAudio(
                        mediaSessionController
                    )
                    result.success(res)
                }

            }
        }

    }

    private fun requestAudioStoragePermission(){
         if(VERSION.SDK_INT >= VERSION_CODES.TIRAMISU){
            if(ActivityCompat.checkSelfPermission(this,Manifest.permission.READ_MEDIA_AUDIO) ==
                PackageManager.PERMISSION_DENIED){
                 ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.READ_MEDIA_AUDIO),
                     READ_MUSIC_REQUEST_CODE)
            }else{
                 Log.d("Music","Already have permission")
            }
        }
    }


    private fun openDirectoryPicker(res: MethodChannel.Result){
        val intent:Intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        intent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
        intent.addFlags(Intent.FLAG_GRANT_PREFIX_URI_PERMISSION)
        intent.addFlags(Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
        startActivityForResult(intent, REQUEST_CODE_OPEN_DIRECTORY)
        resultPending = res
    }

    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?,
        caller: ComponentCaller
    ) {
        if(requestCode == REQUEST_CODE_OPEN_DIRECTORY){
         if(resultCode == Activity.RESULT_OK){
             val uri:Uri?= data?.data

             uri?.let {
                 contentResolver.takePersistableUriPermission(
                     it,
                     Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                 )
                 val subDirs = folderLoad.loadSubDirectoriesFromRootDirectories(this,it)
                 resultPending?.success(subDirs)
             }?:run {
                 resultPending?.error("NULL_URI","NO Uri found",null)
             }
         }else{
             resultPending?.error("CANCELLED", "user cancelled directory picking", null)
         }
            resultPending = null
        }else {
            super.onActivityResult(requestCode, resultCode, data, caller)
        }
    }

}













