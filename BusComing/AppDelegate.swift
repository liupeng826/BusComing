//
//  AppDelegate.swift
//  BusComing
//
//  Created by Peng Liu on 16-10-29.
//  Copyright (c) 2016 LiuPeng. All rights reserved.
//

import UIKit

let APIKey = "e3ce847a0401148b546b389cb31e447c"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    //后台任务
//    var backgroundTask:UIBackgroundTaskIdentifier! = nil
//    let locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        AMapServices.shared().enableHTTPS = true
        AMapServices.shared().apiKey = APIKey
        
        // 后台持续定位（被杀掉的情况下可以唤醒）
//        if launchOptions?[UIApplicationLaunchOptionsKey.location] != nil {
//            
//            if #available(iOS 8.0, *) {
//                locationManager.requestAlwaysAuthorization()
//            }
//            //这是iOS9中针对后台定位推出的新属性 不设置的话 可是会出现顶部蓝条的哦(类似热点连接)
//            if #available(iOS 9.0, *) {
//                locationManager.allowsBackgroundLocationUpdates = true
//            }
//            locationManager.startMonitoringSignificantLocationChanges()
//        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        let vc = application.keyWindow?.rootViewController
        print("main vc :\(String(describing: vc))")
        // viewController!.stopLocationIfNeeded()
        
//        //如果已存在后台任务，先将其设为完成
//        if self.backgroundTask != nil {
//            application.endBackgroundTask(self.backgroundTask)
//            self.backgroundTask = UIBackgroundTaskInvalid
//        }
//        
//        //注册后台任务
//        self.backgroundTask = application.beginBackgroundTask(expirationHandler: {
//            () -> Void in
//            //如果没有调用endBackgroundTask，时间耗尽时应用程序将被终止
//            application.endBackgroundTask(self.backgroundTask)
//            self.backgroundTask = UIBackgroundTaskInvalid
//        })
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

