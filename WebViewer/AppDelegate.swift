//
//  AppDelegate.swift
//  WebViewer
//
//  Created by Amit Gaikwad on 02/03/18.
//  Copyright © 2018 Amit Gaikwad. All rights reserved.
//

import UIKit
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, OSPermissionObserver, OSSubscriptionObserver {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UINavigationBar.appearance().isHidden = isNavigationBarDisabled        
        UINavigationBar.appearance().barTintColor = kAppThemeColor
        UINavigationBar.appearance().tintColor = kAppThemeColor
        
        UINavigationBar.appearance().barStyle = .blackOpaque
        
        //Notification using One Signal
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { [weak self] notification in
            print("Received Notification: \(notification!.payload.notificationID)")
            print("launchURL = \(notification?.payload.launchURL ?? "None")")
            print("content_available = \(notification?.payload.contentAvailable ?? false)")
        }
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { [weak self] result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload? = result?.notification.payload
            let bodyUrl: URL? = payload?.body.getUrl()
            let additionalData: Dictionary? = result?.notification.payload?.additionalData
            let launchUrlStr: String? = result?.notification.payload.launchURL
            print("payload = \(String(describing: payload))")
            print("additionalData = \(String(describing: additionalData))")
            print("launchUrlStr = \(String(describing: launchUrlStr))")
            if  launchUrlStr != nil || additionalData != nil || bodyUrl != nil {
                var launchUrl: URL? = nil
                if launchUrl != nil {   //Launch Url
                    launchUrl = URL(string: launchUrlStr ?? "")
                } else if additionalData != nil {   //Additional Data Url
                    launchUrl = URL(string: (result?.notification.payload?.additionalData["OpenURL"] as? String) ?? "")
                } else if bodyUrl != nil {
                     launchUrl = bodyUrl
                } else {
                    launchUrl = URL(string: kWebUrl)
                }
                
                print("additionalData = \(String(describing: launchUrl))")
                print("urlStr = \(String(describing: bodyUrl))")
                self?.makeDeepLinkToWebView(url: launchUrl!)
                
                if let actionSelected = payload?.actionButtons {
                    print("actionSelected = \(actionSelected)")
                }
                
                // DEEP LINK from action buttons
                if let actionID = result?.action.actionID {
                    
                    // For presenting a ViewController from push notification action button
//                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                    let instantiateRedViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "RedViewControllerID") as UIViewController
//                    let instantiatedGreenViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "GreenViewControllerID") as UIViewController
//                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    
                    print("actionID = \(actionID)")
                    
                    if actionID == "id2" {
                        print("do something when button 2 is pressed")
//                        self.window?.rootViewController = instantiateRedViewController
//                        self.window?.makeKeyAndVisible()
                        
                        
                    } else if actionID == "id1" {
                        print("do something when button 1 is pressed")
//                        self.window?.rootViewController = instantiatedGreenViewController
//                        self.window?.makeKeyAndVisible()
                        
                    }
                }
            }
        }
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false, kOSSettingsKeyInAppLaunchURL: true, ]
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: kOneSignalAppId, handleNotificationReceived: notificationReceivedBlock, handleNotificationAction: notificationOpenedBlock, settings: onesignalInitSettings)
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
        
        
        // Add your AppDelegate as an obsserver
        OneSignal.add(self as OSPermissionObserver)

        OneSignal.add(self as OSSubscriptionObserver)
        
        //Register for push notification
        onRegisterForPushNotificationsButton()
        
        do {
            Network.reachability = try Reachability(hostname: kWebUrl)
            do {
                try Network.reachability?.start()
            } catch let error as Network.Error {
                print(error)
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
        
        //application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert , .badge , .sound], categories: nil))
        
        return true
    }
    
    func makeDeepLinkToWebView(url: URL) {
        // DEEP LINK and open url in RedViewController
        print("In AppDelegate.makeDeepLinkToWebView")
        if let webViewCtrl = (self.window?.rootViewController as? UINavigationController)?.viewControllers.first as? WebViewController {
            DispatchQueue.main.async { [weak self] in
                /// The presenting view controllers view doesn't get removed from the window as its currently transistioning and presenting a view controller
                if let transitionViewClass = NSClassFromString("UITransitionView") {
                    for subview in (UIApplication.shared.keyWindow?.subviews ?? []) where subview.isKind(of: transitionViewClass) {
                        subview.removeFromSuperview()
                        print("UITransitionView Removed")
                    }
                } else {
                    print("No UITransitionView Found")
                }
                webViewCtrl.receivedURL = url
                webViewCtrl.loadWebView()
                self?.window?.rootViewController?.navigationController?.navigationBar.isHidden = isNavigationBarDisabled
            }
        } else {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let webViewController : WebViewController = mainStoryboard.instantiateViewController(withIdentifier: "WebViewControllerID") as! WebViewController
            webViewController.receivedURL = url
            let navigationController = UINavigationController(rootViewController: webViewController)
            DispatchQueue.main.async { [weak self] in
                navigationController.navigationBar.isHidden = isNavigationBarDisabled
                self?.window?.rootViewController = navigationController
            }
        }
    }
    
    // Add this new method
    func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges!) {
        
        // Example of detecting answering the permission prompt
        if stateChanges.from.status == OSNotificationPermission.notDetermined {
            if stateChanges.to.status == OSNotificationPermission.authorized {
                print("Thanks for accepting notifications!")
            } else if stateChanges.to.status == OSNotificationPermission.denied {
                print("Notifications not accepted. You can turn them on later under your iOS settings.")
            }
        }
        // prints out all properties
        print("PermissionStateChanges: \n\(stateChanges)")
    }
    
    // Output:
    /*
     Thanks for accepting notifications!
     PermissionStateChanges:
     Optional(<OSSubscriptionStateChanges:
     from: <OSPermissionState: hasPrompted: 0, status: NotDetermined>,
     to:   <OSPermissionState: hasPrompted: 1, status: Authorized>
     >
     */
    
    // TODO: update docs to change method name
    // Add this new method
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            print("Subscribed for OneSignal push notifications!")
        }
        print("SubscriptionStateChange: \n\(stateChanges)")
    }
    
    // Output:
    
    /*
     Subscribed for OneSignal push notifications!
     PermissionStateChanges:
     Optional(<OSSubscriptionStateChanges:
     from: <OSSubscriptionState: userId: (null), pushToken: 0000000000000000000000000000000000000000000000000000000000000000 userSubscriptionSetting: 1, subscribed: 0>,
     to:   <OSSubscriptionState: userId: 11111111-222-333-444-555555555555, pushToken: 0000000000000000000000000000000000000000000000000000000000000000, userSubscriptionSetting: 1, subscribed: 1>
     >
     */
    
    func onRegisterForPushNotificationsButton() {
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        if status.permissionStatus.status != .denied {
            // Call when you want to prompt the user to accept push notifications.
            // Only call once and only if you set kOSSettingsKeyAutoPrompt in AppDelegate to false.
            OneSignal.promptForPushNotifications(userResponse: { accepted in
                if accepted == true {
                    print("User accepted notifications: \(accepted)")
                } else {
                    print("User accepted notifications: \(accepted)")
                }
            })
        } else {
            displaySettingsNotification()
        }
    }
    
    func displaySettingsNotification() {
        let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .`default`, handler: { action in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        });
        self.displayAlert(title: "Alert", message: "Please enable your notification setting  by going to Settings > Notifications > Allow Notifications. You will not received any notification until and unless you turn it on.", actions: [UIAlertAction.okAction(), settingsAction]);
    }
    
    func displayAlert(title : String, message: String, actions: [UIAlertAction]) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert);
        actions.forEach { controller.addAction($0) };
        DispatchQueue.main.async { [weak self] in
            self?.window?.rootViewController?.present(controller, animated: true, completion: nil);
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        let webViewCtrl = (window?.rootViewController as? UINavigationController)?.viewControllers.first as? WebViewController
        webViewCtrl?.refreshWevView()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
//            self?.scheduleLocal()
//        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // handle any deeplink
        DispatchQueue.main.async {
            Deeplinker.checkDeepLink()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: Deeplinks
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return Deeplinker.handleDeeplink(url: url)
    }
    
    // MARK: Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                return Deeplinker.handleDeeplink(url: url)
            }
        }
        return false
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //print("\(deviceToken.hexString())")
        print("In didRegisterForRemoteNotificationsWithDeviceToken call to loadWebView")
        let webViewCtrl = (window?.rootViewController as? UINavigationController)?.viewControllers.first as? WebViewController
        webViewCtrl?.loadWebView()
    }
}

//extension Data {
//    func hexString() -> String {
//        return self.reduce("") { string, byte in
//            string + String(format: "%02X", byte)
//        }
//    }
//}

extension UIAlertAction {
    static func okAction() -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil);
    }
}

//extension AppDelegate {
//    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
//        let bodyUrl: URL? = notification.alertBody?.getUrl()
//        print("bodyUrl = \(String(describing: bodyUrl))")
//        print("urlStr = \(String(describing: bodyUrl))")
//        makeDeepLinkToWebView(url: bodyUrl!)
//    }
//
//    func scheduleLocal() {
//        let notification = UILocalNotification()
//        notification.fireDate = Date()
//        notification.alertTitle = "Test"
//        notification.alertBody = "http://google.com"
//        notification.soundName = UILocalNotificationDefaultSoundName
//        UIApplication.shared.scheduleLocalNotification(notification)
//    }
//}

