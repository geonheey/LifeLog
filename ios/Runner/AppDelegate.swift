import UIKit
import WebKit
import Firebase
import FirebaseCore
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Firebase initialization
        FirebaseApp.configure()

        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "com.example.to_do_list/task_channel",
                                           binaryMessenger: controller.binaryMessenger)

        channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "updateTasks":
                self.updateTasks(call: call, result: result)
            case "updateDiaries":
                self.updateDiaries(call: call, result: result)
            case "getTasks":
                self.getTasks(call: call, result: result)
            case "getDiaries":
                self.getDiaries(call: call, result: result)
            case "getAllTasks":
                self.getAllTasks(call: call, result: result)
            case "getAllDiaries":
                self.getAllDiaries(call: call, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // 할 일 업데이트
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

    // 일기 업데이트
    func updateDiaries(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let date = args["date"] as? String,
              let diaries = args["diaries"] as? [[String: Any]] else {
            print("Invalid arguments: \(String(describing: call.arguments))")
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing arguments", details: nil))
            return
        }

        let ref = Database.database().reference().child("diaries").child(date)
        ref.setValue(diaries) { error, _ in
            if let error = error {
                print("Error updating diaries: \(error.localizedDescription)")
                result(FlutterError(code: "ERROR", message: "Failed to update diaries", details: nil))
            } else {
                print("Diaries updated for date: \(date)")
                result("Diaries updated successfully.")
            }
        }
    }

    // 특정 날짜의 할 일 가져오기
    func getTasks(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let date = args["date"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing date argument", details: nil))
            return
        }

        let ref = Database.database().reference().child("tasks").child(date)
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(), let tasksList = snapshot.value as? [[String: Any]] {
                print("date: \(date), tasks: \(tasksList)")
                result(tasksList)
            } else {
                result([])
            }
        } withCancel: { error in
            print("Error getting tasks: \(error.localizedDescription)")
            result(FlutterError(code: "ERROR", message: "Failed to get tasks", details: nil))
        }
    }

    // 특정 날짜의 일기 가져오기
    func getDiaries(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let date = args["date"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing date argument", details: nil))
            return
        }

        let ref = Database.database().reference().child("diaries").child(date)
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(), let diaryList = snapshot.value as? [[String: Any]] {
                print("date: \(date), diaries: \(diaryList)")
                result(diaryList)
            } else {
                result([])
            }
        } withCancel: { error in
            print("Error getting diaries: \(error.localizedDescription)")
            result(FlutterError(code: "ERROR", message: "Failed to get diaries", details: nil))
        }
    }

    // 모든 할 일 가져오기
   func getAllTasks(call: FlutterMethodCall, result: @escaping FlutterResult) {
       let ref = Database.database().reference().child("tasks")
       ref.observeSingleEvent(of: .value) { snapshot in
           if snapshot.exists(), let data = snapshot.value as? [String: Any] {
               print("All tasks: \(data)")
               result(data)
           } else {
               result([:])
           }
       } withCancel: { error in
           print("Error getting all tasks: \(error.localizedDescription)")
           result(FlutterError(code: "ERROR", message: "Failed to get all tasks", details: nil))
       }
   }

    // 모든 일기 가져오기
    func getAllDiaries(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let ref = Database.database().reference().child("diaries")
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(), let data = snapshot.value as? [String: Any] {
                print("All diaries: \(data)")
                result(data)
            } else {
                result([:])
            }
        } withCancel: { error in
            print("Error getting all diaries: \(error.localizedDescription)")
            result(FlutterError(code: "ERROR", message: "Failed to get all diaries", details: nil))
        }
    }
}