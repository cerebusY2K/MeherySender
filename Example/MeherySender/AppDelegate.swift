import UIKit
import UserNotifications
import MeherySender // Ensure this is the correct import for your SDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize your SDK
        let meSend = MeSend.shared
        
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION", title: "Accept", options: [.foreground])
        let rejectAction = UNNotificationAction(identifier: "REJECT_ACTION", title: "Reject", options: [])
        meSend.setCategoryForNotification(categoryName: "ACCEPT_REJECT", actions: [acceptAction,rejectAction])
        
        // Request notification authorization
        requestNotificationAuthorization()
        
        return true
    }

    func requestNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else if let error = error {
                print("Error while requesting authorization: \(error.localizedDescription)")
            }
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        MeSend.shared.sendDeviceTokenToServer(deviceToken: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
}
