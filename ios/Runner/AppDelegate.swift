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
        FirebaseApp.configure()
Database.database().isPersistenceEnabled = true
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "com.example.to_do_list/task_channel",
                                           binaryMessenger: controller.binaryMessenger)

        channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "updateTasks": self.updateTasks(call: call, result: result)
            case "updateDiaries": self.updateDiaries(call: call, result: result)
            case "getTasks": self.getTasks(call: call, result: result)
            case "getDiaries": self.getDiaries(call: call, result: result)
            case "getAllTasks": self.getAllTasks(call: call, result: result)
            case "getAllDiaries": self.getAllDiaries(call: call, result: result)
            case "getAllDays": self.getAllDays(call: call, result: result)
            case "updateDays": self.updateDays(call: call, result: result)
            case "getDays": self.getDays(call: call, result: result)
            default: result(FlutterMethodNotImplemented)
            }
        }
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // 앱이 백그라운드로 전환될 때 호출
    override func applicationDidEnterBackground(_ application: UIApplication) {
        print("App entered background")
        
        // 선택된 날짜 저장
        let selectedDate = _formatDate(Date())
        UserDefaults.standard.set(selectedDate, forKey: "lastSelectedDate")
    }
    // 앱이 다시 포그라운드로 돌아올 때 호출
    override func applicationWillEnterForeground(_ application: UIApplication) {
        print("App will enter foreground")
        // Flutter 측에 상태 복구 요청 가능
    }

    // 현재 날짜를 포맷팅하는 헬퍼 함수
    private func _formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: date)
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

    // day 업데이트
    func updateDays(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let date = args["date"] as? String,
              let days = args["days"] as? [[String: Any]] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing arguments", details: nil))
            return
        }

        let ref = Database.database().reference().child("days").child(date)
        ref.setValue(days) { error, _ in
            if let error = error {
                print("Error updating days: \(error.localizedDescription)")
                result(FlutterError(code: "ERROR", message: "Failed to update days", details: nil))
            } else {
                print("Days updated for date: \(date)")
                result("Days updated successfully.")
            }
        }
    }

    // 특정 날짜의 day 가져오기
    func getDays(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let date = args["date"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing date argument", details: nil))
            return
        }

        let ref = Database.database().reference().child("days").child(date)
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(), let daysList = snapshot.value as? [[String: Any]] {
                print("date: \(date), days: \(daysList)")
                result(daysList)
            } else {
                result([])
            }
        } withCancel: { error in
            print("Error getting days: \(error.localizedDescription)")
            result(FlutterError(code: "ERROR", message: "Failed to get days", details: nil))
        }
    }

    // 모든 day 가져오기
    func getAllDays(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let ref = Database.database().reference().child("days")
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(), let data = snapshot.value as? [String: Any] {
                print("All days: \(data)")
                result(data)
            } else {
                result([:])
            }
        } withCancel: { error in
            print("Error getting all days: \(error.localizedDescription)")
            result(FlutterError(code: "ERROR", message: "Failed to get all days", details: nil))
        }
    }

}
