import Flutter
import UIKit

public class FlutterApnsPlugin: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate {
  let messEvent = MessageEventChannel()
  var deviceToken : String?
  private var deviceTokenContinuation: CheckedContinuation<String, Error>?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_apns", binaryMessenger: registrar.messenger())
    let instance = FlutterApnsPlugin()

    let eventChannel = FlutterEventChannel(name: "flutter_apns/events", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(instance.messEvent)

    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addApplicationDelegate(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate

    switch call.method {
      case "getPlatformVersion":
        result("iOS " + UIDevice.current.systemVersion)

      case "requestPermissions":
        self.requestPermissions(result: result)

      case "register":
        Task {
          if let token = self.deviceToken as String? {
            result(token)
          } else {
            do {
              let token = try await self.registerForPushNotifications()
              self.deviceToken = token
              result(token)
            } catch {
              result(FlutterError(
                code: "TOKEN_ERROR",
                message: "Failed to get device token",
                details: error.localizedDescription
              ))
            }
          }
        }

      case "unregister":
        self.unregisterForPushNotifications()
        self.deviceToken = nil
        result(true)

      default:
        result(FlutterMethodNotImplemented)
    }
  }



  public func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]
  ) -> Bool {
    /* DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.sendData(userInfo: ["Hello":"World"])
    } */

    // Check if the app was launched from a remote notification.
    if let notification = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
      // If so, send the notification data to your event channel.
      self.sendData(userInfo: notification)
    }

    return true
  }

  public func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    // Resume the continuation with the successful token
    deviceTokenContinuation?.resume(returning: token)
    deviceTokenContinuation = nil
  }

  public func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    // Resume the continuation with an error
    deviceTokenContinuation?.resume(throwing: error)
    deviceTokenContinuation = nil
  }



  public func registerForPushNotifications() async throws -> String {
    return try await withCheckedThrowingContinuation { continuation in
      // Store the continuation to be resumed later
      self.deviceTokenContinuation = continuation
      // Initiate the registration process
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
  }

  public func requestPermissions(result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if let error = error {
        result(FlutterError(
          code: "PERMISSION_ERROR",
          message: "Failed to request permissions",
          details: error.localizedDescription
        ))
      } else {
        result(granted)
      }
    }
  }

  public func unregisterForPushNotifications() {
    DispatchQueue.main.async {
      UIApplication.shared.unregisterForRemoteNotifications()
    }
  }



  public func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // let userInfo = notification.request.content.userInfo
    // sendData(userInfo: userInfo)

    if #available(iOS 14.0, *) {
      completionHandler([.banner, .list, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }

  public func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    sendData(userInfo: userInfo)

    completionHandler()
  }

  public func sendData(userInfo: [AnyHashable: Any]) {
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: userInfo, options: [])
      if let jsonString = String(data: jsonData, encoding: .utf8) {
        print(jsonString);
        messEvent.sendData(jsonString);
      }
    } catch {
      print("Error converting JSON to string: \(error)")
    }
  }
}

class MessageEventChannel: NSObject, FlutterStreamHandler {
  private var sink:FlutterEventSink? = nil
  private var messageWhenAppKilled: String? = nil

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    sink = events
    if let mess = messageWhenAppKilled {
      sendData(mess)
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    sink = nil
    return nil
  }

  func sendData(_ data: String?) {
    if sink == nil {
      messageWhenAppKilled = data
    }
    if data == nil {return}
    self.sink?(data)
    return
  }
}




