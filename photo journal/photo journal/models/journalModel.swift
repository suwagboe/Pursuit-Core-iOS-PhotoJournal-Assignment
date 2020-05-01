//
//  journalModel.swift
//  photo journal
//
//  Created by Pursuit on 2/12/20.
//  Copyright © 2020 Pursuit. All rights reserved.
//

import Foundation

struct JournalModel: Codable & Equatable {
    let image: ImageObject
    let description: String    
}
