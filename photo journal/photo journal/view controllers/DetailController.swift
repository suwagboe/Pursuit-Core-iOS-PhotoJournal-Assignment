//
//  DetailController.swift
//  photo journal
//
//  Created by Pursuit on 1/30/20.
//  Copyright © 2020 Pursuit. All rights reserved.
//

import UIKit
import AVFoundation

protocol EditJournalEntryDelegate: AnyObject {
    func editEntry(oldEntry: JournalModel, newEntry: JournalModel)
}

class DetailController: UIViewController {
    
    @IBOutlet weak var addedPhoto: UIImageView?
    @IBOutlet weak var detailsOfImage: UITextView?
    
    @IBOutlet weak var textField: UITextField!
    
    
    weak var instanceOfCustomDelegate : EditJournalEntryDelegate?
    private let imagePickerDelegate = UIImagePickerController()
    
    //    let dp = DataPersistence<JournalModel>(filename: "photos.plist")
    // variables for when the user is editing
    private var editingEntry : Bool?
    private var editingImage : UIImage?
    private var editingText: String?
    
    var givenJournaEntry: JournalModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        //detailsOfImage?.delegate = self
        imagePickerDelegate.delegate = self
        configureDetailController()
        
    }
    
    func configureDetailController(){
        guard let model = givenJournaEntry else {
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
    
    private func textWasChanged() -> JournalModel {
        var entry: JournalModel?
        
        if editingText == nil {
            if let photoData =  addedPhoto?.image?.jpegData(compressionQuality: 1.0) {
                  let updatedImageObject = ImageObject(imageData:photoData, date: Date())

                          entry = JournalModel(image: updatedImageObject, description: (detailsOfImage?.text!)! )
                            }
             } else {
                 // if the text was changed do this
               // addedPhoto?.image
                     print("the selectedImage is not appending properly")
                       let size = UIScreen.main.bounds.size
            let rect = AVMakeRect(aspectRatio: (addedPhoto?.image!.size)!, insideRect: CGRect(origin: CGPoint.zero, size: size))
            let resizedPhoto = addedPhoto?.image!.resizeImage(width: rect.size.width, height: rect.size.height)
            if let photoData = resizedPhoto!.jpegData(compressionQuality: 1.0)  {
                                     let updatedImageObject = ImageObject(imageData: photoData, date: Date())
                                        
                                     entry = JournalModel(image: updatedImageObject, description: editingText!)
                                  }
                }
        return entry!
    }
    
    @IBAction func updateEntry(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(identifier: "ViewController") as? ViewController else {
            fatalError("couldnt access DetailController")
        }
           // textWasChanged()
            //dpInDetail.updateOne(givenJournaEntry!, with: newJournalEntry) // to update based on what is typed
            do {
                try vc.dp.createAEntry(journalEntry: textWasChanged())
            } catch {
                print("error = \(error)")
            }
            print("the create section is working")
            
            instanceOfCustomDelegate?.editEntry(oldEntry: givenJournaEntry!, newEntry: textWasChanged())
            dismiss(animated: true)
            
        }
        
        
    } // end of class
/*
 extension DetailController: UITextViewDelegate {
 func textViewDidEndEditing(_ textView: UITextView) {
 
 }
 
 func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
 guard let text = textView.text else {
 print("the text was not properly captured")
 return false
 }
 
 detailsOfImage?.text = text
 editingText = text
 textView.resignFirstResponder()
 return true
 }
 }
 
 */


extension DetailController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        //textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.isEmpty == true {
            showAlert(title: "Youre not done yet", message: "Hey.. sorry to say it but you need to type something into the description or else how will we know.. ")
        } else {
            guard let text = textField.text else {
                return false
            }
            editingText = text
            print(editingText)
        }
        
        
        textField.resignFirstResponder()
        return true
    }
}


extension DetailController: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true) // when they click cancel it will dismiss
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // gains access to the selected media
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            print("image cannot be found, try again")
            return
        }// now I have access to the image that was clicked
        print("editingImage before the it being selected it \(editingImage)")
        editingImage = image
        DispatchQueue.main.async {
            self.addedPhoto?.image = image
        }
        print("editing image is now = \(editingImage)")
        
        dismiss(animated: true)
        
    }
    
}
