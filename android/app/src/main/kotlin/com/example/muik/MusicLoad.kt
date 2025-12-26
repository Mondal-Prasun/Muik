package com.example.muik

import android.content.ContentUris
import android.content.Context
import android.net.Uri
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.util.Log

class MusicLoad {

    fun getMusicMetaDataFromDirectory(context: Context,contentUri: Uri): List<Map<String, String>>{
        val audioList = mutableListOf<Map<String, String>>()
        val relativePath = getRelativePath(contentUri);

        val collection = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.DURATION,
        )

        val selection = "${MediaStore.Audio.Media.IS_MUSIC} != 0 AND ${MediaStore.Audio.Media.RELATIVE_PATH} LIKE ?"

        val selectionArg = arrayOf("$relativePath%")
        val sortOrder = "${MediaStore.Audio.Media.DATE_ADDED} DESC"

        context.contentResolver?.query(
            collection,
            projection,
            selection,
            selectionArg,
            sortOrder
        )?.use { cursor ->
             val idCol = cursor.getColumnIndex(MediaStore.Audio.Media._ID)
             while(cursor.moveToNext()){
                 val id = cursor.getLong(idCol)

                 val uri = ContentUris.withAppendedId(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, id)
                 val title = cursor.getString(cursor.getColumnIndex(MediaStore.Audio.Media.TITLE))
                 val artist = cursor.getString(cursor.getColumnIndex(MediaStore.Audio.Media.ARTIST))
                 val duration = cursor.getLong(cursor.getColumnIndex(MediaStore.Audio.Media.DURATION))

                 audioList.add(mapOf<String, String>(
                     "uri" to uri.toString(),
                     "title" to title,
                     "artist" to artist,
                     "duration" to duration.toString(),
                 ))
             }
        }
        return audioList
    }


    fun getMusicCount(context: Context, contentUri: Uri): Int{
        val relativePath = getRelativePath(contentUri)
        val projection = arrayOf("COUNT(${MediaStore.Audio.Media._ID})")

        val selection = """
        ${MediaStore.Audio.Media.IS_MUSIC} != 0
        AND ${MediaStore.Audio.Media.RELATIVE_PATH} LIKE ?
    """.trimIndent()

        val selectionArgs = arrayOf("$relativePath%")

        context.contentResolver.query(
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
            projection,
            selection,
            selectionArgs,
            null
        )?.use { cursor ->
            if (cursor.moveToFirst()) {
                return cursor.getInt(0)
            }
        }
        return 0
    }



    private fun getRelativePath(contentUri: Uri): String?{

        val p = DocumentsContract.getTreeDocumentId(contentUri);
        Log.d("MusicLoadDirec", "Path $p")
        val sp = p.split(":")
        if (sp.size < 2) return null
        return sp[1] + "/";
    }
}