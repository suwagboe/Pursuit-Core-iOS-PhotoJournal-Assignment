//
//  File Manager.swift
//  photo journal
//
//  Created by Pursuit on 1/29/20.
//  Copyright © 2020 Pursuit. All rights reserved.
//

import Foundation

extension FileManager{
    
    static func getDocumentsDirectory() -> URL{
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    static func pathToDocumentsDirectory(with fileName: String) -> URL{
        return getDocumentsDirectory().appendingPathComponent(fileName)
        
        
    }
}
