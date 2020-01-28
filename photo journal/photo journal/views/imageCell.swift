//
//  imageCell.swift
//  photo journal
//
//  Created by Pursuit on 1/27/20.
//  Copyright © 2020 Pursuit. All rights reserved.
//

import UIKit

protocol ImageCellDelegate: AnyObject {
    // this is for a custom delegate
    func didLongPress(_ imageCell: ImageCell)
}

class ImageCell{
    
    @IBOutlet weak var imageView: UIImageView!
    
    // need a weak instance of the custom delegate
    // need reference in order to access the protocol method inside of it
    weak var imageDelegateReference: ImageCellDelegate?
    
    // 1: SetUp
    private lazy var longPressGesture: UILongPressGestureRecognizer = {
        // why are you calling it within itself...
        let gesture = UILongPressGestureRecognizer()
        
        gesture.addTarget(self, action: #selector(longPressAction(gesture:)))
        return gesture
        
            }()
//    
//    override func layoutSubviews() {
//      super.layoutSubviews()
//      layer.cornerRadius = 20.0
//      backgroundColor = .orange
//
//      // step 3
//    //  addGestureRecognizer(longPressGesture)
//    }
  
    
//    override func layoutSubViews() {
//
//        super.layoutSubViews
//        layer.cornerRadius = 20.0
//            // figure out how to make this pink.. or sparkely
//        backgroundColor = .purple
//
//        //3. need to add the gesture recoginzer
//    }
    
    //2. function to hold the actual commands for the action
    
    @objc
    private func longPressAction(gesture: UILongPressGestureRecognizer) {
        // this is built off of objective c run time so the code in here needs to explict.
        
        if gesture.state == .began {// if it is happening then...
            gesture.state = .cancelled
            // at this point it should have stopped.
            return
        }
        
        // why is it calling itself again...
        imageDelegateReference?.didLongPress(self)
    }
    
    public func configureCell(imageObject: ImageObject){
        guard let image = UIImage(data: imageObject.imageData) else {
            return
        }
        
        imageView.image = image
    }
    
}
