//
//  imageCell.swift
//  photo journal
//
//  Created by Pursuit on 1/27/20.
//  Copyright © 2020 Pursuit. All rights reserved.
//

import Foundation
import UIKit

protocol CellDelegate: AnyObject {
    // this is for a custom delegate
    func didLongPress(_ imageCell: JournalEntryCell)
}

class JournalEntryCell: UICollectionViewCell {
    
    // MARK: 
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var extraActionsButton: UIButton!
    
    // need a weak instance of the custom delegate
    // need reference in order to access the protocol method inside of it
    weak var JournalEntryDelegateReference: CellDelegate?
    
    // 1: SetUp
    private lazy var longPressGesture: UILongPressGestureRecognizer = {
        // why are you calling it within itself...
        let gesture = UILongPressGestureRecognizer()
        
        gesture.addTarget(self, action: #selector(longPressAction(gesture:)))
        return gesture
        
            }()
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 20.0
        backgroundColor = .magenta
        
            // step 3
        addGestureRecognizer(longPressGesture)
    }
    
    @objc
    private func longPressAction(gesture: UILongPressGestureRecognizer) {
        // this is built off of objective c run time so the code in here needs to explict.
        
        if gesture.state == .began {// if it is happening then...
            gesture.state = .cancelled
            // at this point it should have stopped.
            return
        }
        
        // why is it calling itself again...
        JournalEntryDelegateReference?.didLongPress(self)
    }
    
    public func configureCell(journalEntry: JournalModel){
        guard let image = UIImage(data: journalEntry.image.imageData) else {
            return
        }
        
        imageView.image = image
        descriptionLabel.text = journalEntry.description
        
    }
    
    
    public func segueBackToMain(){
        
    //    let mainC = ViewController()
        
      //  when they are done I should be able to segue back to the first/main controller.
        
    }
    
}
