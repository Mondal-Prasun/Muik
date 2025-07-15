package com.example.muik

import android.Manifest
import android.app.Activity
import android.app.ComponentCaller
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ComponentName
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity

//This is libraries to get native apis

import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.media3.session.MediaController
import androidx.media3.session.SessionToken
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Objects




class MainActivity : FlutterActivity(){

    companion object{
        private const val DART_CHANNEL = "Android_Channel_Music"
        private const val READ_MUSIC_REQUEST_CODE = 101
        private const val REQUEST_CODE_OPEN_DIRECTORY = 42
        private var mediaSessionController:MediaController?= null
    }

    private var resultPending:MethodChannel.Result? = null


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

    }

    @RequiresApi(VERSION_CODES.O)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        //requesting media storage permission
         requestAudioStoragePermisson()
        //initializing  MusicLoadService
         val musicLoadService : MusicLoadService = MusicLoadService(this)






        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DART_CHANNEL
        ).setMethodCallHandler { call, result ->

            when(call.method){
                "pickPreferredDirectory" ->{
                       openDirectoryPicker(result)
                }

                "loadMusicFromStorage" ->{
                    val allData = musicLoadService.loadMusicFromStorage(this,"")
                    val musicMapData = mutableListOf<Map<String,Any>>()

                    if (allData.isNotEmpty()){
                       allData.forEach {
                           musicMapData.add(mapOf<String,Any>(
                               "id" to "${it.id}",
                               "name" to it.name,
                               "uri" to "${it.uri}",
                               "duration" to it.duration,
                               "absolutePath" to it.absolutePath,
                           ))
                       }
                    }else{
                        Log.d("Error","Music is empty")
                        result.error("404","Cannot found any audio",
                            "Storage is not exist or is empty")
                    }
                        result.success(musicMapData)
                }

                "startMusic" ->{
                    val sUri:String? = call.arguments<String>()
                    musicLoadService.playAudio(sUri!!, mediaSessionController)
                }

                "pauseMusic" ->{

                }
                "resumeMusic" ->{

                }
                "isMusicPlaying" ->{


                }
            }

        }
    }




    private fun requestAudioStoragePermisson(){
         if(VERSION.SDK_INT >= VERSION_CODES.TIRAMISU){
            if(ActivityCompat.checkSelfPermission(this,Manifest.permission.READ_MEDIA_AUDIO) ==
                PackageManager.PERMISSION_DENIED){
                 ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.READ_MEDIA_AUDIO),
                     READ_MUSIC_REQUEST_CODE)
            }else{
                 Log.d("Music","Already have permisson")
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
                 resultPending?.success(it.toString())
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













