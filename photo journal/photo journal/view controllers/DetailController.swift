//
//  DetailController.swift
//  photo journal
//
//  Created by Pursuit on 1/30/20.
//  Copyright © 2020 Pursuit. All rights reserved.
//

import UIKit
import AVFoundation

class DetailController: UIViewController {
    
    @IBOutlet weak var addedPhoto: UIImageView?
    @IBOutlet weak var detailsOfImage: UITextView?
    
    private let imagePickerDelegate = UIImagePickerController()
    
    public var dpInDetail = DataPersistence<JournalModel>(filename: "photos.plist")
    //    let dp = DataPersistence<JournalModel>(filename: "photos.plist")

    
    var seletedImage: JournalModel?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        detailsOfImage?.delegate = self
        configureDetailController()

    }
    
    func configureDetailController(){
        guard let model = seletedImage else {
            return
        }
        addedPhoto?.image = UIImage(data: model.image.imageData)
        detailsOfImage?.text = model.description
    }
  

    private func updateJournalEntries() {
        
    }
    private func showImageController(isCameraSelected: Bool){
          
          imagePickerDelegate.sourceType = .photoLibrary
          
          if isCameraSelected {
              imagePickerDelegate.sourceType = .photoLibrary
          }
          present(imagePickerDelegate, animated: true)
          
      }
    
    
    @IBAction func changeThePhoto(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
              
              let cameraAction = UIAlertAction(title: "Camera", style: .default) {
                  [weak self] alertAction in
                  self?.showImageController(isCameraSelected: true)
                 
              }
              
              let photoLibraryAction = UIAlertAction(title: "photo library", style: .default) {
                  [weak self] alertAction in
                  self?.showImageController(isCameraSelected: false)
              }
              let cancelAction = UIAlertAction(title: "cancel", style: .cancel)
          
              alertController.addAction(cancelAction)
              alertController.addAction(cameraAction)
              alertController.addAction(photoLibraryAction)
              present(alertController, animated: true)
        
    }
    
    @IBAction func updateEntry(_ sender: UIButton) {
        
        guard let vc = storyboard?.instantiateViewController(identifier: "ViewController") as? ViewController else {
                         fatalError("couldnt access DetailController")
                     }
        
        guard let objectOfImage = seletedImage?.image else {
                   print("the selectedImage is not appending properly")
            return
               }
        
        guard let text = detailsOfImage?.text else {
            print("couldnt access the info inside of the text view")
            return
        }
        
        var newJournalEntry = JournalModel(image: objectOfImage, description: text)
               
               do {
                
                   try vc.dp.createAEntry(journalEntry: newJournalEntry)
              //  vc.journalEntries.append(appendEntry) - should not access this variable here
               // try dpInDetail.updateOne(seletedImage!, with: newJournalEntry)
               } catch {
                  print("the error is inside of detail controller: \(error)")
                print("the entry did not append")
               }
    dismiss(animated: true)
    }

    
}

extension DetailController: UITextViewDelegate {
    
    
}

extension DetailController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty == true {
            showAlert(title: "Youre not done yet", message: "Hey.. sorry to say it but you need to type something into the description or else how will we know.. ")
        }
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
             textField.resignFirstResponder()
             return true
         }
    }

//extension DetailController:
// add the extension on UIImage for the long press so that way it pops up and they can change the image

