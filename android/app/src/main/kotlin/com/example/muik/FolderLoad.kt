package com.example.muik


import android.content.Context
import android.net.Uri
import android.provider.DocumentsContract
import androidx.core.provider.DocumentsContractCompat.DocumentCompat
import androidx.documentfile.provider.DocumentFile


class FolderLoad {

    fun loadSubDirectoriesFromRootDirectories(context : Context , uri:Uri):MutableList<Map<String,String>>{
          val subDirectories = mutableListOf<Map<String,String>>()
        val rootDir = DocumentFile.fromTreeUri(context, uri)
        if(rootDir != null && rootDir.isDirectory){
            for(file in rootDir.listFiles()){
                if (file.isDirectory) {
//                   println("Subfolders : ${file.name} and uri is : ${file.uri}")
                    subDirectories.add(
                        mapOf<String, String>(
                            "name" to file.name!!,
                            "uri" to file.uri.toString()
                        )
                    )
                }
            }
        }
        return subDirectories;
    }

    fun loadContentFromDirectories(context: Context , uri:Uri):MutableList<Map<String,String>>{
        val contentDirectory = DocumentFile.fromTreeUri(context, uri)
        val allContent = mutableListOf<Map<String, String>>()
        if (contentDirectory != null && contentDirectory.isDirectory ){
            for(file in contentDirectory.listFiles()){
                if (file.isFile) {
//                    println("Subfolders : ${file.name} and uri is : ${file.uri}")
                    allContent.add(
                        mapOf<String, String>(
                            "name" to file.name!!,
                            "uri" to file.uri.toString()
                        )
                    )
                }
            }
        }
        return allContent
    }


}