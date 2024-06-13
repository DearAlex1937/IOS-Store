//
//  AppDelegate.swift
//  Store
//
//  Created by edy on 2024/5/29.
//

import UIKit
import CoreData
import SQLite3

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var db: OpaquePointer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // 创建数据库
        db = createDatabase()
        // 插入初始数据
        insertSampleDataIfNeeded(db: db)
        return true
    }
    

    // MARK: UISceneSession Lifecycle

    func createDatabase() -> OpaquePointer?{
        var db: OpaquePointer? = nil
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("TCMDatabase.sqlite")
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK{
            print("无法打开数据库")
            return nil
        }
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS TCMS(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            description TEXT,
            price REAL,
            imageUrl TEXT,
            category TEXT
        )
        """
        
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK{
            print("无法创建表")
            return nil
        }
        return db
    }
    
    // 插入初始数据方法
        func insertSampleDataIfNeeded(db: OpaquePointer?) {
            let checkDataQuery = "SELECT COUNT(*) FROM TCMS"
            var stmt: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, checkDataQuery, -1, &stmt, nil) == SQLITE_OK {
                if sqlite3_step(stmt) == SQLITE_ROW {
                    let count = sqlite3_column_int(stmt, 0)
                    if count == 0 {
                        insertSampleData(db: db)
                    }else{
                        let deleteQuery = "DELETE FROM TCMS"
                        if sqlite3_exec(db, deleteQuery, nil, nil, nil) != SQLITE_OK {
                            print("无法删除数据")
                            return
                        }
                        insertSampleData(db: db)
                    }
                }
            }
            
            sqlite3_finalize(stmt)
        }

        func insertSampleData(db: OpaquePointer?) {
            let insertQuery1 = "INSERT INTO TCMS (name, description, price, imageUrl, category) VALUES ('人参', '补气养血', 120.0, 'renshen.jpg','草本类')"
            let insertQuery2 = "INSERT INTO TCMS (name, description, price, imageUrl, category) VALUES ('枸杞', '益气固表', 30.0, 'gouqi.jpg','果实种子类')"
            let insertQuery3 = "INSERT INTO TCMS (name, description, price, imageUrl, category) VALUES ('黄芪', '益气固表', 50.0, 'huangqi.jpg','根及根茎类')"

            if sqlite3_exec(db, insertQuery1, nil, nil, nil) != SQLITE_OK ||
               sqlite3_exec(db, insertQuery2, nil, nil, nil) != SQLITE_OK ||
               sqlite3_exec(db, insertQuery3, nil, nil, nil) != SQLITE_OK {
                print("无法插入数据")
                return
            }
//            let insertQuery = "INSERT INTO TCM (name, description, price, imageUrl) VALUES (?, ?, ?, ?)"
//
//            var stmt: OpaquePointer? = nil
//
//            if sqlite3_prepare_v2(db, insertQuery, -1, &stmt, nil) == SQLITE_OK {
//                let sampleData = [
//                    ("人参", "补气养血", 120.0, "Assets/renshen.jpg"),
//                    ("枸杞", "滋补肝肾", 30.0, "Assets/gouqi.jpg"),
//                    ("黄芪", "益气固表", 50.0, "Assets/huangqi.jpg")
//                ]
//
//                for (name, description, price, imageUrl) in sampleData {
//                    sqlite3_bind_text(stmt, 1, name, -1, nil)
//                    sqlite3_bind_text(stmt, 2, description, -1, nil)
//                    sqlite3_bind_double(stmt, 3, price)
//                    sqlite3_bind_text(stmt, 4, imageUrl, -1, nil)
//
//                    if sqlite3_step(stmt) == SQLITE_DONE {
//                        print("插入成功")
//                    } else {
//                        print("插入失败")
//                    }
//
//                    sqlite3_reset(stmt)
//                }
//
//            }
//
//            sqlite3_finalize(stmt)
        }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Store")
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

}

