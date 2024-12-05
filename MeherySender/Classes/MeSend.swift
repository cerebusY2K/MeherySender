import Foundation
import UIKit
import UserNotifications

public class MeSend: NSObject {
    
    public static let shared = MeSend()
    private let notificationHandler = NotificationHandler()
    
    private override init() {
        super.init()
        setupNotificationHandler()
    }
    
    private func setupNotificationHandler() {
        notificationHandler.setup()
        requestNotificationAuthorization()
    }
    
    private func requestNotificationAuthorization() {        
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
    
    public func setCategoryForNotification(categoryName : String,actions : [UNNotificationAction]){
        notificationHandler.setCategoryForNotification(categoryName : categoryName,actions: actions)
    }
    
    public func handleImageAttachment(for notification: UNNotificationRequest, with contentHandler: @escaping (UNNotificationContent) -> Void) {
        notificationHandler.handleImageAttachment(for: notification, with: contentHandler)
    }
    
    public func sendDeviceTokenToServer(deviceToken: Data) {
        var token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        guard let url = URL(string: "https://c9e8-45-114-248-30.ngrok-free.app/api/register") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        print(token)

        let parameters = ["token": token, "platform": "ios","device_id" : deviceId]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending token to server: \(error)")
                return
            }
            if let data = data {
                let responseString = String(data: data, encoding: .utf8)
                print("Response from server: \(responseString ?? "")")
            }
        }
        task.resume()
    }
    
    // New method to get the bundle identifier
        private func getBundleIdentifier() -> String? {
            return Bundle.main.bundleIdentifier
        }
}

class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    
    func setup() {
        UNUserNotificationCenter.current().delegate = self
    }
    
    // Handle incoming notifications and download image if present
    func handleImageAttachment(for request: UNNotificationRequest, with contentHandler: @escaping (UNNotificationContent) -> Void) {
        var bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        // Check if the notification payload contains a "media-url" for the image
        if let mediaURLString = bestAttemptContent?.userInfo["media-url"] as? String,
           let mediaURL = URL(string: mediaURLString) {
            // Download the image
            downloadImage(from: mediaURL) { localURL in
                if let localURL = localURL {
                    // Attach the image as an attachment to the notification
                    self.attachImage(localURL) { attachment in
                        if let attachment = attachment {
                            bestAttemptContent?.attachments = [attachment]
                        }
                        // Return the modified content
                        contentHandler(bestAttemptContent ?? request.content)
                    }
                } else {
                    // No image, just return the original content
                    contentHandler(bestAttemptContent ?? request.content)
                }
            }
        } else {
            // No image, just return the original content
            contentHandler(bestAttemptContent ?? request.content)
        }
    }
    
    private func downloadImage(from url: URL, completion: @escaping (URL?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }

            // Create a temporary file URL to save the image
            let tempDirectory = FileManager.default.temporaryDirectory
            let tempURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")

            do {
                try data.write(to: tempURL)
                completion(tempURL) // Return the URL of the saved image
            } catch {
                print("Failed to save image to temporary directory: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }

    private func attachImage(_ imageURL: URL, completion: @escaping (UNNotificationAttachment?) -> Void) {
        do {
            // Create an attachment with the image URL
            let attachment = try UNNotificationAttachment(identifier: "imageAttachment", url: imageURL, options: nil)
            completion(attachment)
        } catch {
            print("Failed to create image attachment: \(error.localizedDescription)")
            completion(nil)
        }
    }
        
        // Save UIImage to a file and return as a UNNotificationAttachment
        private func saveImageToAttachment(image: UIImage) -> UNNotificationAttachment? {
            let directory = FileManager.default.temporaryDirectory
            let fileURL = directory.appendingPathComponent("image.jpg")
            
            do {
                try image.jpegData(compressionQuality: 1.0)?.write(to: fileURL)
                let attachment = try UNNotificationAttachment(identifier: "image", url: fileURL, options: nil)
                return attachment
            } catch {
                print("Failed to create image attachment: \(error)")
                return nil
            }
        }
    
    
    func setCategoryForNotification(categoryName : String,actions : [UNNotificationAction]){
        UNUserNotificationCenter.current().delegate = self
        let category = UNNotificationCategory(identifier: categoryName, actions: actions, intentIdentifiers: [], options: [])
            
            UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    // This method should be implemented in AppDelegate, not here.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        MeSend.shared.sendDeviceTokenToServer(deviceToken: deviceToken)
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
}
