//
//  CoreDataManager.swift
//  GithubExplorer
//
//  Created by Misha Vrana on 20.06.2023.
//

import Foundation
import CoreData

// Creating a singletone for the CoreData manager

class CoreDataManager {
    static let instance = CoreDataManager()
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    init() {
        container = NSPersistentContainer(name: "GithubExplorerContainer")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error loading core data \(error)")
            }
        }
        context = container.viewContext
    }
    
    func save() {
        do { try context.save() }
        catch { return }
    }
}
