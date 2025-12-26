package com.example.muik

import android.Manifest
import android.app.Activity
import android.app.ComponentCaller


import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences

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
import androidx.core.content.edit
import androidx.lifecycle.lifecycleScope


class MainActivity : FlutterActivity(){

        private val DART_CHANNEL = "Android_Channel_Music"
        private val FLUTTER_CHANNEL_FOR_PLAY = "Flutter_Channel_Music/Play"
        private val FLUTTER_CHANNEL_FOR_META = "Flutter_Channel_Music/Meta"
        private val FLUTTER_CHANNEL_FOR_DU = "Flutter_Channel_Music/Du"

        private val READ_MUSIC_REQUEST_CODE = 101
        private val REQUEST_CODE_OPEN_DIRECTORY = 42
        private var mediaSessionController:MediaController?= null

        private val S_PREF_DATA = "Muik_Data"


    private var resultPending:MethodChannel.Result? = null
    private val musicLoadService : MusicLoadService = MusicLoadService()
    private val musicLoad : MusicLoad = MusicLoad()

    private var selectedDirectory : Uri? = null

    private var flEngine : FlutterEngine? = null

    private var kJob : Job? = null


    override fun onStart() {
        super.onStart()

        val flChannelPlay = MethodChannel(flEngine!!.dartExecutor.binaryMessenger, FLUTTER_CHANNEL_FOR_PLAY)
        val flChannelMeta = MethodChannel(flEngine!!.dartExecutor.binaryMessenger, FLUTTER_CHANNEL_FOR_META)
        val flChannelDu = MethodChannel(flEngine!!.dartExecutor.binaryMessenger, FLUTTER_CHANNEL_FOR_DU)


        val sessionToken = SessionToken(context.applicationContext,
            ComponentName(context.applicationContext,MusicMediaSessionService::class.java)
        )
        val factory = MediaController.Builder(context.applicationContext,sessionToken).buildAsync()
        factory.addListener(
            {
                mediaSessionController = factory.get()


                mediaSessionController?.addListener(object : Player.Listener{

                    override fun onEvents(player: Player, events: Player.Events) {
                        if(events.contains(MediaController.EVENT_PLAYBACK_STATE_CHANGED) || events.contains(MediaController.EVENT_IS_PLAYING_CHANGED)){
                            flChannelPlay.invokeMethod("IsKtMusicPlaying",mediaSessionController?.isPlaying())
                            kJob?.cancel()
                            kJob = lifecycleScope.launch {
                                while(isActive) {
                                    Log.d(
                                        "Music",
                                        "currentPosition: ${mediaSessionController!!.currentPosition}"
                                    )
                                    flChannelDu.invokeMethod("GetCurrentDuPos", mediaSessionController!!.currentPosition.toString())
                                    delay(1000)
                                }
                            }
                            if(!mediaSessionController!!.isPlaying()){
                                kJob?.cancel("Not Playing the music")
                            }
                        }

                        if(events.contains(MediaController.EVENT_MEDIA_METADATA_CHANGED) || events.contains(
                                MediaController.EVENT_MEDIA_ITEM_TRANSITION)){
                            flChannelMeta.invokeMethod("MediaChanged", mapOf<String,String>(
                                "name" to mediaSessionController!!.mediaMetadata.title.toString(),
                                "artist" to mediaSessionController!!.mediaMetadata.artist.toString(),
                                "duration" to mediaSessionController!!.duration.toString()
                            ))
                        }
                    }

                })


            },
            ContextCompat.getMainExecutor(this@MainActivity)

        )


    }



    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        //requesting media storage permission
         requestAudioStoragePermission()
        flEngine = flutterEngine

         val sPref : SharedPreferences = getSharedPreferences(S_PREF_DATA, MODE_PRIVATE)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DART_CHANNEL
        ).setMethodCallHandler { call, result ->

            when(call.method){
                "pickPreferredDirectory" ->{
                       openDirectoryPicker(result)
                }

                "getMusicCount" ->{
                    val count = musicLoad.getMusicCount(this, selectedDirectory!!)
                    result.success(count)
                }

                "setSharePref" ->{
                    try {
                      val arg = call.arguments<Map<String, String>>()
                        sPref.edit {
                            putString(arg?.keys?.first(), arg?.values?.first())
                            apply()
                        }
                    }catch (e: Exception){
                        Log.d("Sharepref","$e")
                        result.error("SHARE PREF", "${e.message}", null)
                    }
                }

                "getSharePref" ->{
                    try{
                        val arg = call.arguments<String>()
                        val value = sPref.getString(arg, null)
                        result.success(value)
                    }catch (e: Exception){
                        Log.d("Sharepref","$e")
                        result.error("SHARE PREF", "${e.message}", null)
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
                    val art = musicLoadService.getAudioThumbnail(mediaSessionController)
                    result.success(art)
                }
                "nextMusic" ->{
                    val res = musicLoadService.nextAudio(
                        mediaSessionController
                    )
                    result.success(res)
                }
                "prevMusic" ->{
                    val res = musicLoadService.prevAudio(
                        mediaSessionController
                    )
                    result.success(res)
                }
                "getNextMediaItemData" ->{
                    val count = call.arguments<Int>()
                    var mList:List<Map<String,Any?>> = listOf()
                    if(count != null){
                        mList = musicLoadService.getNextMediaItemMetaData(mediaSessionController, count);
                    }
                    result.success(mList)
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

                 selectedDirectory = it

                 val allMusic = musicLoad.getMusicMetaDataFromDirectory(context, it)
                 resultPending?.success(allMusic)

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