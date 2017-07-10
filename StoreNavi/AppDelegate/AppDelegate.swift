//
//  AppDelegate.swift
//  StoreNavi
//
//  Created by Gaurang Makawana on 16/01/17.
//  Copyright © 2017 Gaurang Makawana. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var arrSelectedProductList = [ProductModel]()
    
    //For location Manager
    var locationManager: CLLocationManager = CLLocationManager()
    var deferringUpdates: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:
        
        [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        
        //Customization of status bar
        //UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().tintColor = UIColor.white
        //UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().clipsToBounds = false
        
        UINavigationBar.appearance().backgroundColor = UIColor(red: 29.0/255.0, green: 135.0/255.0, blue: 187.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().barTintColor = UIColor(red: 29.0/255.0, green: 135.0/255.0, blue: 187.0/255.0, alpha: 1.0)
        
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : (UIFont(name: "Carnas-Regular", size: 18))!, NSForegroundColorAttributeName: UIColor.white]
        
        //need to updatestatus bar light content
        UIApplication.shared.statusBarStyle = .lightContent
        
        
        //Check if saved record exits
        //If once store data saved next time user should be redirected to store selection screen
        let fm = FileManager.default
        let fileURL:URL = try! fm.url(for:.libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let strFileURL = fileURL.appendingPathComponent("file.plist").path
        if let responseDict:Dictionary<String,AnyObject> = NSDictionary(contentsOfFile: strFileURL) as? Dictionary<String,AnyObject> {
            print("responseDict : \(responseDict)")
            
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let findStoreVC:FindStoreVC = mainStoryboard.instantiateViewController(withIdentifier: "FindStoreVC") as! FindStoreVC
            let navigationController:UINavigationController = self.window?.rootViewController as! UINavigationController
            navigationController.setViewControllers([findStoreVC], animated: true)
            
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
        }
        
        //start Location
        startLocationUpdates()
        
        return true
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
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        if #available(iOS 10.0, *) {
            self.saveContext()
        } else {
            // Fallback on earlier versions
        }
    }

    // MARK: - Core Data stack
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "StoreNavi")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    @available(iOS 10.0, *)
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK: Location Manager
    func startLocationUpdates() {
        // Create a location manager object
        
        // Set the delegate
        self.locationManager.delegate = self
        if #available(iOS 9.0, *) {
            self.locationManager.allowsBackgroundLocationUpdates = true
        } else {
            // Fallback on earlier versions
        }
        
        // Request location authorization
        self.locationManager.requestAlwaysAuthorization()
        
        // Specify the type of activity your app is currently performing
        self.locationManager.activityType = .fitness//CLActivityTypeFitness
        
        // Start location updates
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Add the new locations
        print(locations)
        
        // Defer updates until the user hikes a certain distance or a period of time has passed
        if (!deferringUpdates) {
            let distance: CLLocationDistance = 0.5
            let time: TimeInterval = CLTimeIntervalMax//nextUpdate.timeIntervalSinceNow()
            print("time = \(time) : distance = \(distance)")
            if self.window?.rootViewController is MapViewController{
                let vc:MapViewController = self.window?.rootViewController as! MapViewController
                vc.didUpdateLocation(locations: locations)
            }
            else if (self.window?.rootViewController as! UINavigationController).viewControllers.last is MapViewController {
                
                let vc:MapViewController = (self.window?.rootViewController as! UINavigationController).viewControllers.last as! MapViewController
                vc.didUpdateLocation(locations: locations)
            }
            
            self.locationManager.allowDeferredLocationUpdates(untilTraveled: distance, timeout:time)
            deferringUpdates = true;
        } else {
            dispatchNotif("\(locations.first!.coordinate.latitude),\(locations.first!.coordinate.longitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        // Stop deferring updates
        self.deferringUpdates = false
        
        // Adjust for the next goal
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        //dispatchNotif(error.localizedDescription)
        
        if self.window?.rootViewController is MapViewController{
            let vc:MapViewController = self.window?.rootViewController as! MapViewController
            vc.didFailWithError()
        }
        else if (self.window?.rootViewController as! UINavigationController).viewControllers.last is MapViewController {
            
            let vc:MapViewController = (self.window?.rootViewController as! UINavigationController).viewControllers.last as! MapViewController
            vc.didFailWithError()
        }
    }
    
    
    //MARK:- Local Notification
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        //		let v = UIAlertView(title: "ALERT", message: notification.alertBody, delegate: nil, cancelButtonTitle: "OK")
        //		v.show()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "prova"), object: notification, userInfo: ["text" : notification.alertBody ?? ""])
    }
    
    func dispatchNotif(_ text: String) {
        let notification = UILocalNotification()
        if #available(iOS 8.2, *) {
            notification.alertTitle = "NOTIF"
        } else {
            // Fallback on earlier versions
        }
        notification.alertBody = "\(text)"
        notification.fireDate = Date()
        UIApplication.shared.scheduleLocalNotification(notification)
    }

}

