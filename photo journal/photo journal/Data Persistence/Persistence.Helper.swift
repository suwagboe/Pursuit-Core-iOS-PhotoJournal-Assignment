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
    
    private var photos = [T]()
    
    private var filename: String
    
    // this initialies the name to get reinitialized...
    init(filename: String) {
        self.filename = filename
    }
    
    private func savePhoto() throws {
        // assign the url to the url that allows access to the location inside of the device
        let url = FileManager.pathToDocumentsDirectory(with: filename)
            print(url)
        
        do {
            // conver the photo into data
            let data = try PropertyListEncoder().encode(photos)
            
            // want the photo converted to data to added into the location of the url
            try data.write(to: url, options: .atomic)
            
        } catch {
            throw DataPersistenceError.savingError(error)
        }
    }


// to update the array after the item is deleted
    public func rearrangePhotos(photos: [T]) {
        // can this line be reexplained please
    self.photos = photos
        
        // this resaves it?
        try? savePhoto()
}
    
    
    public func createPhotos(aPhoto: T) throws{
        // reminder of why certain functions need a throw
        photos.append(aPhoto)
        
        do {
            try savePhoto()
        } catch {
            throw DataPersistenceError.savingError(error)
        }
    }

    public func loadPhotos() throws -> [T] {
        
        let url = FileManager.pathToDocumentsDirectory(with: filename)
        
        if FileManager.default.fileExists(atPath: url.path) {
            if let data = FileManager.default.contents(atPath: url.path) {
                do {
                    // why do you need self here is it saying to check the photos self above.
                    photos = try PropertyListDecoder().decode([T].self, from: data)
                } catch {
                    throw DataPersistenceError.decodingError(error)
                }
            } else {
                throw DataPersistenceError.noData
            }
        } else {
            throw DataPersistenceError.fileDoesNotExist(filename)
        }
        return photos
    }
    
    public func delete(photos index: Int) throws {
        photos.remove(at: index)
    }
    
    //update
    
    @discardableResult
    // this updates the location???
    public func update(_ oldItems: T, with newItem: T) -> Bool {
        if let index = photos.firstIndex(of: oldItems) {
            let result = update(newItem, at: index)
            
            return result
        }
        return false //
    }
    
    @discardableResult
    // does this one update after it is deleted
    public func update(_ aphoto: T, at Index: Int) -> Bool {
        
        photos[Index] = aphoto
        
        do {
            try savePhoto()
            return true
        } catch {
            return false
        }
    }
    
    public func deletePhoto(at Index: Int) throws {
        
        let deletedItem = photos.remove(at: Index)
        
        do {
            try savePhoto()
            delegate?.didDeleteItem(self, item: deletedItem)
        } catch {
            throw DataPersistenceError.deletingError(error)
        }
        
    }
    
}
