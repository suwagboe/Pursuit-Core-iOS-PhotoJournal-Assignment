//
//  imageCell.swift
//  photo journal
//
//  Created by Pursuit on 1/27/20.
//  Copyright © 2020 Pursuit. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol EditButtonDelegate: AnyObject {
    // this is for a custom delegate
    func editButtonPressed(indexOfEntry: Int, _ imageCell: JournalEntryCell)
    
}

class JournalEntryCell: UICollectionViewCell {
    
    // MARK: 
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var EditButton: UIButton!
    @IBOutlet weak var extraActionsButton: UIButton!
    
    // need a weak instance of the custom delegate
    // need reference in order to access the protocol method inside of it
    weak var JournalEntryEditButtonDelegateReference: EditButtonDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 20.0
        backgroundColor = .magenta
        
    }
 
    public func configureCell(journalEntry: JournalModel){
        guard let image = UIImage(data: journalEntry.image.imageData) else {
            return
        }

        imageView.image = image
        descriptionLabel.text = journalEntry.description
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
JournalEntryEditButtonDelegateReference?.editButtonPressed(indexOfEntry: 0, self)
        print("edit button pressed...")
    }
    
    
} 
