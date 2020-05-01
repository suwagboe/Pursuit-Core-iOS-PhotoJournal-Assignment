//
//  PersistenceHelper.swift
//  photo journal
//
//  Created by Pursuit on 1/29/20.
//  Copyright © 2020 Pursuit. All rights reserved.
//

import Foundation

enum DataPersistenceError: Error{
        case savingError(Error)
        case fileDoesNotExist(String)
        case noData
        case decodingError(Error)
        case deletingError(Error)
    }
// need to do custom delegation.. need it for deleting
protocol dataPersistenceDelegate: AnyObject {
    func didDeleteItem<T>(_ persistenceHelper: DataPersistence<T>, item: T)
}

typealias Writeable = Codable & Equatable

class DataPersistence<T: Writeable> {
    
    weak var delegate: dataPersistenceDelegate?
    
    private var entry = [T]()
    
    private var filename: String
    
    // this initialies the name to get reinitialized...
    init(filename: String) {
        self.filename = filename
    }
    
    private func saveAJournalEntry() throws {
        // assign the url to the url that allows access to the location inside of the device
        let url = FileManager.pathToDocumentsDirectory(with: filename)
            print(url)
        
        do {
            // conver the photo into data
            let data = try PropertyListEncoder().encode(entry)
            
            // want the photo converted to data to added into the location of the url
            try data.write(to: url, options: .atomic)
            
        } catch {
            throw DataPersistenceError.savingError(error)
        }
    }


// to update the array after the item is deleted
    public func rearrangeEntries(entry: [T]) {
        // can this line be reexplained please
    self.entry = entry
        
        // this resaves it?
        try? saveAJournalEntry()
}
    
    
    public func createAEntry(journalEntry: T) throws{
        // reminder of why certain functions need a throw
        
        _ = try loadEntries() // in order to get the older entries I need this 
        
        entry.append(journalEntry)
        
        do {
            try saveAJournalEntry()
        }   catch {
            throw DataPersistenceError.savingError(error)
        }
    }

    public func loadEntries() throws -> [T] {
        
        let url = FileManager.pathToDocumentsDirectory(with: filename)
        
        if FileManager.default.fileExists(atPath: url.path) {
            if let data = FileManager.default.contents(atPath: url.path) {
                do {
                    // why do you need self here is it saying to check the photos self above.
                    entry = try PropertyListDecoder().decode([T].self, from: data)
                } catch {
                    throw DataPersistenceError.decodingError(error)
                }
            } else {
                throw DataPersistenceError.noData
            }
        }
        
        else {
            throw DataPersistenceError.fileDoesNotExist(filename)
        }
        return entry
    }
//
//    public func delete(photos index: Int) throws {
//        entry.remove(at: index)
//    }
//
    //update
    
    @discardableResult
    // this updates the location???
    public func updateOne(_ oldItems: T, with newItem: T) -> Bool {
        if let index = entry.firstIndex(of: oldItems) {
            let result = updateTwo(newItem, at: index)
            
            return result
        }
        return false //
    }
    
    @discardableResult
    // does this one update after it is deleted
    public func updateTwo(_ aEntry: T, at Index: Int) -> Bool {
        
        entry[Index] = aEntry
        
        do {
            try saveAJournalEntry()
            return true
        } catch {
            return false
        }
    }
    
    public func deleteEntry(at Index: Int) throws {
        
       _ = entry.remove(at: Index)
        
        do {
           // delegate?.didDeleteItem(self, item: deletedItem)
            try saveAJournalEntry()
        } catch {
            throw DataPersistenceError.deletingError(error)
        }
        
    }
    
}
