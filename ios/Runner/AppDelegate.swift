import UIKit
//import flutter_downloader
import WebKit
import Firebase
import FirebaseCore
import Flutter

@UIApplicationMain

@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Firebase 초기화
    FirebaseApp.configure()

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.example.to_do_list/task_channel",
                                       binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "updateTasks":
        self.updateTasks(call: call, result: result)
      case "updateDiary":
        self.updateDiary(call: call, result: result)
      case "getTasks":
        self.getTasks(call: call, result: result)
      case "getDiary":
        self.getDiary(call: call, result: result)
      case "getAllTasks":
        self.getAllTasks(call: call, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }


  func updateTasks(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let date = args["date"] as? String,
          let tasks = args["tasks"] as? [[String: Any]] else {
      result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing arguments", details: nil))
      return
    }

    let ref = Database.database().reference().child("tasks").child(date)
    ref.setValue(tasks) { error, _ in
      if let error = error {
        print("Error updating tasks: \(error.localizedDescription)")
        result(FlutterError(code: "ERROR", message: "Failed to update tasks", details: nil))
      } else {
        print("Tasks updated for date: \(date)")
        result("Tasks updated successfully.")
      }
    }
  }

  func updateDiary(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let date = args["date"] as? String,
          let diary = args["diary"] as? [[String: Any]] else {
      result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing arguments", details: nil))
      return
    }

    let ref = Database.database().reference().child("tasks").child(date).child("diary")
    ref.setValue(diary) { error, _ in
      if let error = error {
        print("Error updating diary: \(error.localizedDescription)")
        result(FlutterError(code: "ERROR", message: "Failed to update diary", details: nil))
      } else {
        print("Diary updated for date: \(date)")
        result("Diary updated successfully.")
      }
    }
  }

  func getTasks(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let date = args["date"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing date argument", details: nil))
      return
    }

    let ref = Database.database().reference().child("tasks").child(date)
    ref.observeSingleEvent(of: .value) { snapshot in
      if snapshot.exists() {
        let tasksList = snapshot.value
        print("date: \(date), tasks: \(String(describing: tasksList))")
        result(tasksList)
      } else {
        result([])
      }
    } withCancel: { error in
      print("Error getting tasks: \(error.localizedDescription)")
      result(FlutterError(code: "ERROR", message: "Failed to get tasks", details: nil))
    }
  }

  func getDiary(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let date = args["date"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing date argument", details: nil))
      return
    }

    let ref = Database.database().reference().child("tasks").child(date).child("diary")
    ref.observeSingleEvent(of: .value) { snapshot in
      if snapshot.exists() {
        let diaryList = snapshot.value
        print("date: \(date), diary: \(String(describing: diaryList))")
        result(diaryList)
      } else {
        result([])
      }
    } withCancel: { error in
      print("Error getting diary: \(error.localizedDescription)")
      result(FlutterError(code: "ERROR", message: "Failed to get diary", details: nil))
    }
  }

  func getAllTasks(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let ref = Database.database().reference().child("tasks")
    ref.observeSingleEvent(of: .value) { snapshot in
      if snapshot.exists(), let data = snapshot.value as? [String: Any] {
        print("all tasks: \(data)")
        result(data)
      } else {
        result([:])
      }
    } withCancel: { error in
      print("Error getting all tasks: \(error.localizedDescription)")
      result(FlutterError(code: "ERROR", message: "Failed to get all tasks", details: nil))
    }
  }
}
