package com.example.to_do_list

import android.util.Log
import com.google.firebase.database.DatabaseReference
import com.google.firebase.database.FirebaseDatabase
import com.google.firebase.database.GenericTypeIndicator
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray

class MainActivity : FlutterActivity() {
    private val CHANNEL_NAME = "com.example.to_do_list/task_channel"
    private val TAG = "MainActivity"

    private val database: FirebaseDatabase =
        FirebaseDatabase.getInstance(dotenv.env['FIREBASE_KEY'])
    private val tasksRef: DatabaseReference = database.getReference("tasks")
    private val diariesRef: DatabaseReference = database.getReference("diaries")
    private val daysRef: DatabaseReference = database.getReference("days")

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    "updateTasks" -> {
                        val date = call.argument<String>("date")
                        val tasks = call.argument<List<*>>("tasks")
                        if (date != null && tasks != null) {
                            val jsonArray = JSONArray(tasks)
                            val tasksList = mutableListOf<Map<String, Any>>()
                            for (i in 0 until jsonArray.length()) {
                                val jsonObj = jsonArray.getJSONObject(i)
                                val task = jsonObj.getString("task")
                                val isDone = jsonObj.getBoolean("isDone")
                                tasksList.add(mapOf("task" to task, "isDone" to isDone))
                            }
                            tasksRef.child(date).setValue(tasksList)
                                .addOnSuccessListener {
                                    Log.d(TAG, "Tasks updated for date: $date")
                                    result.success("Tasks updated successfully.")
                                }
                                .addOnFailureListener { e ->
                                    Log.e(TAG, "Error updating tasks", e)
                                    result.error("ERROR", "Failed to update tasks", null)
                                }
                        } else {
                            result.error("INVALID_ARGUMENT", "null", null)
                        }
                    }

                    "updateDiaries" -> {
                        val date = call.argument<String>("date")
                        val diaries = call.argument<List<*>>("diaries")
                        if (date != null && diaries != null) {
                            val diaryList = mutableListOf<Map<String, Any>>()

                            diaries.forEach { item ->
                                if (item is Map<*, *>) {
                                    val diaryEntry = mutableMapOf<String, Any>()
                                    (item as? Map<String, Any>)?.forEach { (key, value) ->
                                        if (key == "diary" && value is String) {
                                            diaryEntry[key] = value
                                        }
                                    }
                                    diaryList.add(diaryEntry)
                                }
                            }



                            diariesRef.child(date).setValue(diaryList)
                                .addOnSuccessListener {
                                    Log.d(TAG, "Diaries updated for date: $date")
                                    result.success("Diaries updated successfully.")
                                }
                                .addOnFailureListener { e ->
                                    Log.e(TAG, "Error updating diaries", e)
                                    result.error("ERROR", "Failed to update diaries", null)
                                }
                        } else {
                            result.error("INVALID_ARGUMENT", "null", null)
                        }
                    }

                    "updateDays" -> {
                        val date = call.argument<String>("date")
                        val days = call.argument<List<*>>("days")
                        if (date != null && days != null) {
                            val dayList = mutableListOf<Map<String, Any>>()
                            days.forEach { item ->
                                if (item is Map<*, *>) {
                                    val dayEntry = mutableMapOf<String, Any>()
                                    (item as? Map<String, Any>)?.forEach { (key, value) ->
                                        if (key == "day" && value is String) {
                                            dayEntry[key] = value
                                        }
                                    }
                                    dayList.add(dayEntry)
                                }
                            }

                            daysRef.child(date).setValue(dayList)
                                .addOnSuccessListener {
                                    Log.d(TAG, "Days updated for date: $date")
                                    result.success("Days updated successfully.")
                                }
                                .addOnFailureListener { e ->
                                    Log.e(TAG, "Error updating days", e)
                                    result.error("ERROR", "Failed to update days", null)
                                }
                        } else {
                            result.error("INVALID_ARGUMENT", "Date or days is null", null)
                        }
                    }

                    "getTasks" -> {
                        val date = call.argument<String>("date")
                        if (date != null) {
                            tasksRef.child(date).get()
                                .addOnSuccessListener { snapshot ->
                                    if (snapshot.exists()) {
                                        val indicator = object :
                                            GenericTypeIndicator<List<Map<String, Any>>>() {}
                                        val tasksList = snapshot.getValue(indicator)
                                            ?: emptyList<Map<String, Any>>()
                                        Log.d(TAG, "date: $date, tasks: $tasksList")
                                        result.success(tasksList)
                                    } else {
                                        result.success(emptyList<Map<String, Any>>())
                                    }
                                }
                                .addOnFailureListener { e ->
                                    Log.e(TAG, "Error getting tasks", e)
                                    result.error("ERROR", "Failed to get tasks", null)
                                }
                        } else {
                            result.error("INVALID_ARGUMENT", "null", null)
                        }
                    }

//                    "getDiaries" -> {
//                        val date = call.argument<String>("date")
//                        if (date != null) {
//                            diariesRef.child(date).get()
//                                .addOnSuccessListener { snapshot ->
//                                    if (snapshot.exists()) {
//                                        val indicator = object :
//                                            GenericTypeIndicator<List<Map<String, Any>>>() {}
//                                        val diaryList = snapshot.getValue(indicator) ?: emptyList()
//                                        val resultList = diaryList.map {
//                                            it["diary"] as? String ?: ""
//                                        }
//                                        result.success(resultList)
//                                    } else {
//                                        result.success(emptyList<String>())
//                                    }
//                                }
//                                .addOnFailureListener { e ->
//                                    Log.e(TAG, "Error getting diaries", e)
//                                    result.error("ERROR", "Failed to get diaries", null)
//                                }
//                        } else {
//                            result.error("INVALID_ARGUMENT", "null", null)
//                        }
//                    }

                    "getAllTasks" -> {
                        tasksRef.get()
                            .addOnSuccessListener { snapshot ->
                                val allTasks = mutableMapOf<String, Any>()
                                for (childSnapshot in snapshot.children) {
                                    val date = childSnapshot.key ?: continue
                                    val indicator =
                                        object : GenericTypeIndicator<List<Map<String, Any>>>() {}
                                    val tasksList = childSnapshot.getValue(indicator)
                                        ?: emptyList<Map<String, Any>>()
                                    allTasks[date] = tasksList
                                }
                                Log.d(TAG, "all tasks: $allTasks")
                                result.success(allTasks)
                            }
                            .addOnFailureListener { e ->
                                Log.e(TAG, "Error getting all tasks", e)
                                result.error("ERROR", "Failed to get all tasks", null)
                            }
                    }

                    "getAllDays" -> {
                        daysRef.get()
                            .addOnSuccessListener { snapshot ->
                                val allDays = mutableMapOf<String, Any>()
                                for (dateSnapshot in snapshot.children) {
                                    val date = dateSnapshot.key ?: continue
                                    val dayList = mutableListOf<Map<String, String>>()
                                    for (indexSnapshot in dateSnapshot.children) {
                                        val dayData = indexSnapshot.getValue(object : GenericTypeIndicator<Map<String, Any>>() {})
                                        if (dayData != null) {
                                            val day = dayData["day"] as? String
                                            if (day != null) {
                                                dayList.add(mapOf("day" to day))
                                            }
                                        }
                                    }
                                    allDays[date] = dayList
                                }

                                Log.d(TAG, "All days: $allDays")
                                result.success(allDays)
                            }
                            .addOnFailureListener { e ->
                                Log.e(TAG, "Error getting all days", e)
                                result.error("ERROR", "Failed to get all days", null)
                            }
                    }
                    "getAllDiaries" -> {
                        diariesRef.get()
                            .addOnSuccessListener { snapshot ->
                                val allDiaries = mutableMapOf<String, Any>()

                                for (dateSnapshot in snapshot.children) {
                                    val date = dateSnapshot.key ?: continue
                                    val diaryList = mutableListOf<Map<String, String>>()

                                    for (indexSnapshot in dateSnapshot.children) {
                                        val diaryData = indexSnapshot.getValue(object : GenericTypeIndicator<Map<String, Any>>() {})
                                        if (diaryData != null) {
                                            val diary = diaryData["diary"] as? String
                                            if (diary != null) {
                                                diaryList.add(mapOf("diary" to diary))
                                            }
                                        }
                                    }

                                    allDiaries[date] = diaryList
                                }

                                result.success(allDiaries)
                            }
                            .addOnFailureListener { e ->
                                Log.e(TAG, "Error getting all diaries", e)
                                result.error("ERROR", "Failed to get all diaries", null)
                            }
                    }


                    else -> result.notImplemented()
                }
            }
    }
}
