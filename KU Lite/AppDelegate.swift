//
//  AppDelegate.swift
//  KU Lite
//
//  Created by Eric on 2019/11/13.
//  Copyright © 2019 ThunPham. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var incognito = false
    var homeUrl = ""


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        homeUrl = self.getHomeurl()
        if homeUrl == "" {
            homeUrl = "https://kubrowser.net/ios"
            self.setHomeurl(value: homeUrl)
        }
        incognito = self.getIncognito()
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
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "KU_Lite")
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
    
    func setIncognito(value: Bool) {
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Incognito")
        
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do { try managedContext.execute(DelAllReqVar) }
        catch { print(error) }
        
        let projectEntity = NSEntityDescription.entity(forEntityName: "Incognito", in: managedContext)!
        
        let language = NSManagedObject(entity: projectEntity, insertInto: managedContext)
        language.setValue(value, forKeyPath: "value")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        self.incognito = value
    }
    
    func getIncognito() -> Bool {
        var result: NSManagedObject? = nil
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Incognito")
        
        do {
            let data = try managedContext.fetch(fetchRequest)
            if data.count > 0 {
                result = data[0] as? NSManagedObject
                return result?.value(forKey: "value") as! Bool
            } else {
                return false
            }
        } catch let error as NSError {
            print("Could not retrieve. \(error), \(error.userInfo)")
        }
        return false
    }
    
    func setHomeurl(value: String) {
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Homeurl")
        
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do { try managedContext.execute(DelAllReqVar) }
        catch { print(error) }
        
        let projectEntity = NSEntityDescription.entity(forEntityName: "Homeurl", in: managedContext)!
        
        let language = NSManagedObject(entity: projectEntity, insertInto: managedContext)
        language.setValue(value, forKeyPath: "value")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        self.homeUrl = value
    }
    
    func getHomeurl() -> String {
        var result: NSManagedObject? = nil
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Homeurl")
        
        do {
            let data = try managedContext.fetch(fetchRequest)
            if data.count > 0 {
                result = data[0] as? NSManagedObject
                return result?.value(forKey: "value") as! String
            } else {
                return ""
            }
        } catch let error as NSError {
            print("Could not retrieve. \(error), \(error.userInfo)")
        }
        return ""
    }
    
    func saveBookmark(title: String, url: String) {
        
        let managedContext = self.persistentContainer.viewContext
        
        let projectEntity = NSEntityDescription.entity(forEntityName: "Bookmarks", in: managedContext)!
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bookmarks")
        
        var lastId = 0
        do {
            let allElementsCount = try managedContext.count(for: fetchRequest)
            if allElementsCount > 0 {
                fetchRequest.fetchLimit = 1
                fetchRequest.fetchOffset = allElementsCount - 1
                fetchRequest.returnsObjectsAsFaults = false
                let result = try managedContext.fetch(fetchRequest)
                let data = result[0] as! NSManagedObject
                lastId = data.value(forKey: "id") as! Int
            }
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        let bookmark = NSManagedObject(entity: projectEntity, insertInto: managedContext)
        bookmark.setValue(lastId+1, forKeyPath: "id")
        bookmark.setValue(title, forKeyPath: "title")
        bookmark.setValue(url, forKeyPath: "url")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func getBookmarks() -> [Any] {
        var result = [Any]()
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bookmarks")
        
        do {
            result = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not retrieve. \(error), \(error.userInfo)")
        }
        return result
    }
    
    func getBookmark(id: Int) -> NSManagedObject {
        var result: NSManagedObject? = nil
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bookmarks")
        fetchRequest.predicate = NSPredicate(format: "id = %i", id)
        
        do {
            let data = try managedContext.fetch(fetchRequest)
            result = data[0] as? NSManagedObject
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return result!
    }
    
    func updateBookmark(id: Int, title: String, url: String) {
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bookmarks")
        fetchRequest.predicate = NSPredicate(format: "id = %i", id)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            let updateObj = result[0] as? NSManagedObject
            updateObj?.setValue(title, forKey: "title")
            updateObj?.setValue(url, forKey: "url")
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not update. \(error), \(error.userInfo)")
            }
        } catch let error as NSError {
            print("Could not update. \(error), \(error.userInfo)")
        }
    }
    
    func deleteBookmark(id: Int) {
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bookmarks")
        fetchRequest.predicate = NSPredicate(format: "id = %i", id)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            let deleteObj = result[0] as! NSManagedObject
            managedContext.delete(deleteObj)
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
            }
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
}

