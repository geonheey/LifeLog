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

    private val database: FirebaseDatabase = FirebaseDatabase.getInstance("https://lifelog-14ee5-default-rtdb.firebaseio.com/")
    private val tasksRef: DatabaseReference = database.getReference("tasks")

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

                    "updateDiary" -> {
                        val date = call.argument<String>("date")
                        val diary = call.argument<List<*>>("diary")
                        if (date != null && diary != null) {
                            val jsonArray = JSONArray(diary)
                            val diaryList = mutableListOf<Map<String, Any>>()
                            for (i in 0 until jsonArray.length()) {
                                val jsonObj = jsonArray.getJSONObject(i)
                                val entry = jsonObj.getString("diary")
                                diaryList.add(mapOf("diary" to entry))
                            }
                            tasksRef.child(date).child("diary").setValue(diaryList)
                                .addOnSuccessListener {
                                    Log.d(TAG, "Diary updated for date: $date")
                                    result.success("Diary updated successfully.")
                                }
                                .addOnFailureListener { e ->
                                    Log.e(TAG, "Error updating diary", e)
                                    result.error("ERROR", "Failed to update diary", null)
                                }
                        } else {
                            result.error("INVALID_ARGUMENT", "null", null)
                        }
                    }

                    "getTasks" -> {
                        val date = call.argument<String>("date")
                        if (date != null) {
                            tasksRef.child(date).get()
                                .addOnSuccessListener { snapshot ->
                                    if (snapshot.exists()) {
                                        val indicator = object : GenericTypeIndicator<List<Map<String, Any>>>() {}
                                        val tasksList = snapshot.getValue(indicator) ?: emptyList<Map<String, Any>>()
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

                    "getDiary" -> {
                        val date = call.argument<String>("date")
                        if (date != null) {
                            tasksRef.child(date).child("diary").get()
                                .addOnSuccessListener { snapshot ->
                                    if (snapshot.exists()) {
                                        val indicator = object : GenericTypeIndicator<List<Map<String, Any>>>() {}
                                        val diaryList = snapshot.getValue(indicator) ?: emptyList<Map<String, Any>>()
                                        Log.d(TAG, "date: $date, diary: $diaryList")
                                        result.success(diaryList)
                                    } else {
                                        result.success(emptyList<Map<String, Any>>())
                                    }
                                }
                                .addOnFailureListener { e ->
                                    Log.e(TAG, "Error getting diary", e)
                                    result.error("ERROR", "Failed to get diary", null)
                                }
                        } else {
                            result.error("INVALID_ARGUMENT", "null", null)
                        }
                    }

                    "getAllTasks" -> {
                        tasksRef.get()
                            .addOnSuccessListener { snapshot ->
                                val allTasks = mutableMapOf<String, Any>()
                                for (childSnapshot in snapshot.children) {
                                    val date = childSnapshot.key ?: continue
                                    val indicator = object : GenericTypeIndicator<List<Map<String, Any>>>() {}
                                    val tasksList = childSnapshot.getValue(indicator) ?: emptyList<Map<String, Any>>()
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

                    else -> result.notImplemented()
                }
            }
    }
}
