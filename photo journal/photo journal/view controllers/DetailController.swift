//
//  DetailController.swift
//  photo journal
//
//  Created by Pursuit on 1/30/20.
//  Copyright © 2020 Pursuit. All rights reserved.
//

import UIKit

class DetailController: UIViewController {
    
    @IBOutlet weak var addedPhoto: UIImageView?
    @IBOutlet weak var detailsOfImage: UITextView?

    var seletedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addedPhoto?.image = seletedImage
    }
    
    
    


}
