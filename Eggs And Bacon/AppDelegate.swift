//
//  AppDelegate.swift
//  Eggs And Bacon
//
//  Created by Romain Arsac on 23/06/2015.
//  Copyright (c) 2015 Nyu Web Developpement. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Parse.enableLocalDatastore()
        Parse.setApplicationId("7vXQaUViTCx03Xth3v6OTx5kk64YrDjuJwYJLI9m", clientKey: "wk1NBzEKqRyV2fJz0bWIzKY9i3TxnFEfyz6k50bU")
        
        let userNotificationTypes = (UIUserNotificationType.Alert |  UIUserNotificationType.Badge |  UIUserNotificationType.Sound);
        
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        //Background
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveEventually { (success:Bool, error:NSError?) -> Void in
            println(error)
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //MARK:  BACKGROUND Fetch
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            
            ManagedPFObject.getDailyPictures { (results, images, error) -> () in
                if error != nil
                {
                    println("Error fetchInBackground")
                    println(error)
                    completionHandler(UIBackgroundFetchResult.Failed)
                }
                else
                {
                    NSNotificationCenter.defaultCenter().postNotificationName("newDatas", object: nil)
                    completionHandler(UIBackgroundFetchResult.NewData)
                }
            }
        })
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in

        
        ManagedPFObject.getDailyPictures { (results, images, error) -> () in
            if error != nil
            {
                println("Error fetchInBackground")
                println(error)
                completionHandler(UIBackgroundFetchResult.Failed)
            }
            else
            {
                NSNotificationCenter.defaultCenter().postNotificationName("newDatas", object: nil)
                completionHandler(UIBackgroundFetchResult.NewData)
            }
        }
        })

    }

}

