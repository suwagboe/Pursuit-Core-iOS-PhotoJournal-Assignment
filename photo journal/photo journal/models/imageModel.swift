//
//  imageModel.swift
//  photo journal
//
//  Created by Pursuit on 1/27/20.
//  Copyright © 2020 Pursuit. All rights reserved.
//

import Foundation

struct ImageObject: Codable & Equatable {
  let imageData: Data
  let date: Date
  let identifier = UUID().uuidString // gives access to unique identifier
}

