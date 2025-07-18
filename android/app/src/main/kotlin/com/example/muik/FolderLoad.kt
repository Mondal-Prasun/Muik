package com.example.muik


import android.content.Context
import android.net.Uri
import androidx.documentfile.provider.DocumentFile


class FolderLoad {

    fun loadSubDirectoriesFromRootDirectories(context : Context , uri:Uri):MutableList<Map<String,String>>{
          val subDirectories = mutableListOf<Map<String,String>>()
        val rootDir = DocumentFile.fromTreeUri(context, uri)
        if(rootDir != null && rootDir.isDirectory){
            rootDir.listFiles().forEach { file->
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
            contentDirectory.listFiles().forEach { file->
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