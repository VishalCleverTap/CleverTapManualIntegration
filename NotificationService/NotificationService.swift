//
//  NotificationService.swift
//  NotificationService
//
//  Created by Vishal More on 29/11/24.
//

import UserNotifications
import CleverTapSDK
import CTNotificationService
import FirebaseMessaging

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    // Define static constants
    let kImage = "image"
    let kVideo = "video"
    let kAudio = "audio"
    let kImageJpeg = "image/jpeg"
    let kImagePng = "image/png"
    let kImageGif = "image/gif"

    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if(CleverTap.sharedInstance()?.isCleverTapNotification(request.content.userInfo) ?? false) {
            
            
            
            let defaults = UserDefaults.init(suiteName: "group.nativeios")
            let logged_in = defaults?.value(forKey: "logged_in")
            let _identity = defaults?.value(forKey: "identity")
            let _email = defaults?.value(forKey: "email")
            
            if ((logged_in) != nil) {
                let profile: Dictionary<String, AnyObject> = [
                    "Identity": _identity as AnyObject,                   // String or number
                    "Email": _email as AnyObject              // Email address of the user
                        ]
                CleverTap.sharedInstance()?.onUserLogin(profile)
                    }
            
            CTNotificationServiceExtension().didReceive(request, withContentHandler: contentHandler)
            
            CleverTap.sharedInstance()?.recordNotificationViewedEvent(withData: request.content.userInfo)
            
            print("From CleverTap")
        } else if(isFCMPushNotification(notification: request.content.userInfo as NSDictionary)) {
            print("From Firebase")
            FIRMessagingExtensionHelper().populateNotificationContent(bestAttemptContent!, withContentHandler: contentHandler)
        }else {
            print("From APNS")
            fromAPNSNotification(request: request, bestAttemptContent: bestAttemptContent!, contentHandler: contentHandler)
            
        }
        }
    
    func fromAPNSNotification(request: UNNotificationRequest,bestAttemptContent: UNMutableNotificationContent,contentHandler:@escaping(UNNotificationContent) -> Void){
        let imageKey = "MediaURL"
        let typeKey = "MediaType"
        let mediaUrl = request.content.userInfo[imageKey]
        let mediaType = request.content.userInfo[typeKey]
        if ((mediaUrl as? String) != nil),
           ((mediaType as? String) != nil) {
            // Proceed with your logic for valid `mediaUrl` and `mediaType`.
        } else {

            if request.content.userInfo[imageKey] == nil {
                print("Unable to add attachment: \(imageKey) is nil")
            }
            if request.content.userInfo[typeKey] == nil {
                print("Unable to add attachment: \(typeKey) is nil")
            }

            contentHandler(bestAttemptContent)
            return
        }
        
        loadAttachment(forUrlString: mediaUrl as! String, withType:mediaType as! String ) { attachment in
            if let attachment = attachment {
                self.bestAttemptContent!.attachments = [attachment]
            }
            contentHandler(self.bestAttemptContent!)
        }
    }
    
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
     func isFCMPushNotification(notification: NSDictionary) -> Bool {
        var isOurs = false
        
         for key in notification.allKeys {
             if (key as AnyObject).hasPrefix("gcm") || (key as AnyObject).hasPrefix("gcm.message_id") {
                    isOurs = true
                    break
                }
            }
        
        return isOurs
    }
    
    
    func loadAttachment(forUrlString urlString: String, withType mediaType: String, completionHandler: @escaping (UNNotificationAttachment?) -> Void) {
        var attachment: UNNotificationAttachment? = nil
        guard let attachmentURL = URL(string: urlString) else {
            completionHandler(nil)
            return
        }

        let session = URLSession(configuration: .default)
        session.downloadTask(with: attachmentURL) { temporaryFileLocation, response, error in
            if let error = error {
                #if DEBUG
                print("Unable to add attachment: \(error.localizedDescription)")
                #endif
            } else if let temporaryFileLocation = temporaryFileLocation,
                      let mimeType = response?.mimeType {
                let fileExt = self.fileExtension(forMediaType: mediaType, mimeType: mimeType)
                let fileManager = FileManager.default
                let localURL = URL(fileURLWithPath: temporaryFileLocation.path + fileExt)
                
                do {
                    try fileManager.moveItem(at: temporaryFileLocation, to: localURL)
                    attachment = try UNNotificationAttachment(identifier: "", url: localURL, options: nil)
                } catch {
                    #if DEBUG
                    print("Unable to add attachment: \(error.localizedDescription)")
                    #endif
                }
            }
            completionHandler(attachment)
        }.resume()
    }

    func fileExtension(forMediaType mediaType: String, mimeType: String) -> String {
        var ext: String
        
        if mediaType == kImage {
            ext = "jpg"
        } else if mediaType == kVideo {
            ext = "mp4"
        } else if mediaType == kAudio {
            ext = "mp3"
        } else {
            // If mediaType is none, check for MIME type of URL.
            if mimeType == kImageJpeg {
                ext = "jpeg"
            } else if mimeType == kImagePng {
                ext = "png"
            } else if mimeType == kImageGif {
                ext = "gif"
            } else {
                ext = ""
            }
        }
        
        return "." + ext
    }


}
