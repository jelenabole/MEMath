//
//  AppDelegate.swift
//  MEMath
//
//  Created by Jelena on 04/01/2019.
//  Copyright © 2019 Jelena. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
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
    }
    
    
    
    
    // TODO - add for Core Data
    
    
    // returns the managed object model for the app
    // if the model doesnt exist, it is created from the app's model
    var _managedObjectModel: NSManagedObjectModel?;
    var managedObjectModel: NSManagedObjectModel {
        if (_managedObjectModel == nil) {
            // TODO - check for the model and show the error if not found:
            guard let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd")
                else {
                    fatalError("Error loading model from bundle");
            }
            _managedObjectModel = NSManagedObjectModel(contentsOf: modelURL);
        }
        return _managedObjectModel!;
    }
    
    // returns the persistent store coordinator for the app
    // if it doesnt exist, create it and the app's store is added to it
    var _persistentStoreCoordinator: NSPersistentStoreCoordinator?;
    var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        if (_persistentStoreCoordinator == nil) {
            let storeURL = self.applicationDocumentsDirectory.appendingPathComponent("Model.sqlite");
            _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel);
            
            do {
                try _persistentStoreCoordinator!.addPersistentStore(
                    ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
                // TODO - add error handling when the persistent store is not accessible or schema is not compatible with the model
                // - abort the app:
                // abort();
            } catch {
                print("ERROR");
            }
            
            
        }
        return _persistentStoreCoordinator!;
    }
    
    
    // returns the managed object context for the application
    // if the context doesnt exist, create it and bound to the persistent store coordinator
    var _managedObjectContext: NSManagedObjectContext?;
    var managedObjectContext: NSManagedObjectContext {
        // TODO - changed from != to ==
        if (_managedObjectContext == nil) {
            let coordinator = self.persistentStoreCoordinator;
            _managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType);
            _managedObjectContext!.persistentStoreCoordinator = coordinator
        }
        return _managedObjectContext!
    }
    
    
    
    // returns the URL to the application's Documents directory
    var applicationDocumentsDirectory: NSURL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask);
        return urls[urls.endIndex - 1] as NSURL;
    }

}
