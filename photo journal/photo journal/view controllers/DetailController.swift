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
  
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let vc = storyboard?.instantiateViewController(identifier: "viewController") as? ViewController else {
//                  fatalError("couldnt access DetailController")
//              }
//        do {
//           try  vc.dp.createAEntry(journalEntry: seletedImage!)
//        } catch {
//           print("the error is inside of detail controller: \(error)")
//        }
//        
//    }
    private func updateJournalEntries() {
        
        
    }
    
    
    @IBAction func updateEntry(_ sender: UIButton) {
        
        guard let vc = storyboard?.instantiateViewController(identifier: "ViewController") as? ViewController else {
                         fatalError("couldnt access DetailController")
                     }
        
        guard let appendEntry = seletedImage else {
                   print("the selectedImage is not appending properly")
            return
               }
               
               do {
                  try  vc.dp.createAEntry(journalEntry: appendEntry)
              //  vc.journalEntries.append(appendEntry) - should not access this variable here

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
