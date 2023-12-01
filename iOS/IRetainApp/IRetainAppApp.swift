//
//  IRetainAppApp.swift
//  IRetainApp
//
//  Created by Kaiburu Sinn on 2023/10/25.
//

import AppAuth
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseMessaging
import SwiftUI
import UIKit
class AppDelegate: UIResponder, UIApplicationDelegate, ObservableObject {
    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    /**
     * 苹果推送注册成功回调，将苹果返回的deviceToken上传到CloudPush服务器
     */
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    /*
     *  苹果推送注册失败回调
     */
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Get deviceToken from APNs failed, error: \(error).")
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    /*
     * App处于启动状态时，通知打开回调（< iOS 10）
     */
    //
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //        MyLog("Receive one notification.")
        //        let aps = userInfo["aps"] as! [AnyHashable : Any]
        //        let sound = aps["sound"] as! String
        //        let type = userInfo["type"] as! String
        //        // 设置角标数为0
        //        application.applicationIconBadgeNumber = 0;
        print("!!!!!!!!!")
        print(userInfo)
        print("successfully receive!")
        completionHandler(.newData)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("!!--------")
        //        print(notification.title)
        //        print(notification.body)
        let content = notification.request.content
        let title = content.title
        let body = content.body
        print("Title: \(title)")
        print("Body: \(body)")
        print("successfully receive!")
        completionHandler(UNNotificationPresentationOptions.alert)
    }
}

@main
struct IRetainAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
//            EditQuestionView(viewModel: .init("TT06PzY9eidu9JeY1eOQ", courseName: "IMAGE & VIDEO PROCESSING", courseId: "ECE588"))
//            QuestionsListView(viewModel: .init(courseId: "ECE588"))
            ContentView()
                .environmentObject(appDelegate)
        }
    }
}
