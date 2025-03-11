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
            case "updateDiary":
                self.updateDiary(call: call, result: result)
            case "getTasks":
                self.getTasks(call: call, result: result)
            case "getDiary":
                self.getDiary(call: call, result: result)
            case "getAllTasks":
                self.getAllTasks(call: call, result: result)
            case "getAllDiary":
                self.getAllDiary(call: call, result: result)
            case "getDiaryForDate":  // Renamed method
                self.getDiaryForDate(call: call, result: result)
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
            print("Invalid arguments: \(String(describing: call.arguments))")
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

    func getAllDiary(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let ref = Database.database().reference().child("tasks")
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                var allDiaries: [String: Any] = [:]
                for child in snapshot.children {
                    guard let childSnapshot = child as? DataSnapshot,
                          let date = childSnapshot.key as String?,
                          let diarySnapshot = childSnapshot.childSnapshot(forPath: "diary").value else {
                        continue
                    }
                    if let diaryList = diarySnapshot as? [[String: Any]] {
                        allDiaries[date] = diaryList
                    } else if let diaryDict = diarySnapshot as? [String: Any] {
                        let diaryList = diaryDict.values.map { $0 as! [String: Any] }
                        allDiaries[date] = diaryList
                    } else {
                        allDiaries[date] = []
                    }
                }
                print("All diaries: \(allDiaries)")
                result(allDiaries)
            } else {
                result([:])
            }
        } withCancel: { error in
            print("Error getting all diaries: \(error.localizedDescription)")
            result(FlutterError(code: "ERROR", message: "Failed to get all diaries", details: nil))
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

    func getDiaryForDate(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let date = args["date"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing date argument", details: nil))
            return
        }

        let ref = Database.database().reference().child("tasks").child(date).child("diary")
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(), let data = snapshot.value as? [String: Any] {
                print("all diaries for \(date): \(data)")
                result(data)
            } else {
                result([:])
            }
        } withCancel: { error in
            print("Error getting diaries for \(date): \(error.localizedDescription)")
            result(FlutterError(code: "ERROR", message: "Failed to get diaries for date", details: nil))
        }
    }
}