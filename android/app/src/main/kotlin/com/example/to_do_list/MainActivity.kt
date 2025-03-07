package com.example.to_do_list

import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray

class MainActivity : FlutterActivity() {
    private val CHANNEL_NAME = "com.example.to_do_list/task_channel"
    private val TAG = "MainActivity"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "updateTasks" -> {
                        val date = call.argument<String>("date")
                        val tasks = call.argument<List<*>>("tasks")
                        if (date != null && tasks != null) {
                            val jsonArray = JSONArray(tasks)
                            val sharedPref: SharedPreferences =
                                getSharedPreferences("Tasks", Context.MODE_PRIVATE)
                            sharedPref.edit().putString(date, jsonArray.toString()).apply()
                            Log.d(TAG, "tasks update: $date, tasks: $tasks")
                        } else {
                            result.error("INVALID_ARGUMENT", " null", null)
                        }
                    }

                    "getTasks" -> {
                        val date = call.argument<String>("date")
                        if (date != null) {
                            val sharedPref: SharedPreferences =
                                getSharedPreferences("Tasks", Context.MODE_PRIVATE)
                            val tasksString = sharedPref.getString(date, null)
                            if (tasksString != null) {
                                val jsonArray = JSONArray(tasksString)
                                val tasksList = mutableListOf<Map<String, Any>>()
                                for (i in 0 until jsonArray.length()) {
                                    val jsonObj = jsonArray.getJSONObject(i)
                                    val task = jsonObj.getString("task")
                                    val isDone = jsonObj.getBoolean("isDone")
                                    tasksList.add(mapOf("task" to task, "isDone" to isDone))
                                }
                                Log.d(TAG, "date: $date, tasks: $tasksList")
                                result.success(tasksList)
                            } else {
                                result.success(emptyList<Map<String, Any>>())
                            }
                        } else {
                            result.error("INVALID_ARGUMENT", "null", null)
                        }
                    }

                    "getAllTasks" -> {
                        val sharedPref: SharedPreferences =
                            getSharedPreferences("Tasks", Context.MODE_PRIVATE)
                        val allEntries = sharedPref.all
                        val allTasks = mutableMapOf<String, Any>()
                        for ((key, value) in allEntries) {
                            // 키, 날짜 형식 (YYYYMMKK) 형식인지 확인
                            if (key.length == 8 && value is String) {
                                try {
                                    val jsonArray = JSONArray(value)
                                    val tasksList = mutableListOf<Map<String, Any>>()
                                    for (i in 0 until jsonArray.length()) {
                                        val jsonObj = jsonArray.getJSONObject(i)
                                        val task = jsonObj.getString("task")
                                        val isDone = jsonObj.getBoolean("isDone")
                                        tasksList.add(mapOf("task" to task, "isDone" to isDone))
                                    }
                                    allTasks[key] = tasksList
                                } catch (e: Exception) {
                                    Log.e(TAG, "Key Error: $key", e)
                                }
                            }
                        }
                        Log.d(TAG, "all tasks: $allTasks")
                        result.success(allTasks)
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
