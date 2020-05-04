//
//  ViewController.swift
//  photo journal
//
//  Created by Pursuit on 1/27/20.
//  Copyright © 2020 Pursuit. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {

    var imagePickerController = UIImagePickerController()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: question 6
    // why is it an optional when in scheduler we banged it.
    // why not the generic ... why the model??
    let dp = DataPersistence<JournalModel>(filename: "photos.plist")
    
    private var journalEntries = [JournalModel]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var photos = [ImageObject]()
    
    private var uploadedPhoto : UIImage?
    
     var uploadedNewEntry: JournalModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        imagePickerController.delegate = self
        loadAllEntries()
            }
    
    override func viewWillAppear(_ animated: Bool) {
        loadAllEntries()
    }

    private func loadAllEntries() {
        do {
            try journalEntries = dp.loadEntries()
        } catch {
            print("here is the error: \(error)")
        }
    }
    
    func segueImageToDetailWithImage(journalEntry: JournalModel, editButtonClicked: Bool? = nil ) {
           guard let dv = storyboard?.instantiateViewController(identifier: "DetailController") as? DetailController else {
               fatalError("couldnt access DetailController")
           }
        
        // need to pass the image...
        dv.givenJournaEntry = journalEntry
        dv.instanceOfCustomDelegate = self
           dv.isModalInPresentation = true
           present(dv, animated: true)
       }
    
    private lazy var dateFormatter: DateFormatter = {
           let formatter = DateFormatter()
           formatter.dateFormat = "EEEE, MMM d, yyyy, hh:mm a"
           formatter.timeZone = .current
           return formatter
       }()
    
    private func appendNewEntry() {
    guard let photo = uploadedPhoto else {
            print("double check that the photo is avaiable...")
            return
        }
        
        print("The original image size is \(photo.size)")
        
        // this is the size of the entire screen
        let size = UIScreen.main.bounds.size
        
       // this is the size that we want the photo to be...
        let rect = AVMakeRect(aspectRatio: photo.size, insideRect: CGRect(origin: CGPoint.zero, size: size))
        
        let resizedPhoto = photo.resizeImage(width: rect.size.width, height: rect.size.height)
        
        print("this is the image after resizing it \(resizedPhoto)")
        
        // converts photo into data
        guard let photoData = resizedPhoto.jpegData(compressionQuality: 1.0) else {
            return
        }
        let justAddedImageObject = ImageObject(imageData: photoData, date: Date())
        
       // photos.insert(justAddedImageObject, at: 0)
        // insert in at the beginning ... of the row and section
        
        
        let indexPath = IndexPath(row: 0, section: 0)
        
        // ????
        let newJorunal = JournalModel(image: justAddedImageObject, description: "Please enter descrpition"
        
        )
        
        journalEntries.insert(newJorunal, at: 0)
        collectionView.insertItems(at: [indexPath])
        
        
//        do {
//            try dp.createAEntry(journalEntry: newJorunal)
//        }catch{
//            print("the error is: \(error)!!!!!!!!!!!!!")
//        }
        
        segueImageToDetailWithImage(journalEntry: newJorunal, editButtonClicked: false)
        
    }

    private func showImageController(isCameraSelected: Bool){
        
        imagePickerController.sourceType = .photoLibrary
        
        if isCameraSelected {
            imagePickerController.sourceType = .photoLibrary
        }
        present(imagePickerController, animated: true)
        
    }

    
    @IBAction func addPictureButtonPressed(_ sender: UIBarButtonItem) {
        
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
}
// this is the custmon delegate that you made
extension ViewController: EditButtonDelegate {
    func editButtonPressed(indexOfEntry: Int, _ imageCell: JournalEntryCell) {
        // this cell was selected...
          let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        guard let indexPath = collectionView.indexPath(for: imageCell) else {
            print("cant access the indexPath")
            return
        }
        
        // this gains access to the sepefic one that was clicked
        let journalEntryClicked = journalEntries[indexPath.row]
        // this gains access to the image data from the selected entry 
      //  let imageFromJournalEntry = journalEntryClicked.image
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
                  [weak self] alertAction in
            do{
              try self?.DeleteEntry(indexPath: indexPath)
            }catch {
                print("couldnt delete inside of editbutton pressed")
            }
              }
        
        let editAction = UIAlertAction(title: "Edit", style: .default) {
            [weak self] alertAction in
            
            self?.segueImageToDetailWithImage(journalEntry: journalEntryClicked, editButtonClicked: true)
            
            // want to set the custom delegate here to watch if the button is pressed
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        alertController.addAction(editAction)
        present(alertController, animated: true) // cant present from inside of a custom cell.
        
    }
    
    private func DeleteEntry(indexPath: IndexPath){
        // when they click delete
        do{
            try dp.deleteEntry(at: indexPath.row)
            
            journalEntries.remove(at: indexPath.row)
           
         //   collectionView.deleteItems(at: [indexPath]) do not delete from collection view since you already did it in the array all you need to do is reload the collection view.
            collectionView.reloadData()
        } catch {
            print("error in deleting \(error)")
        }
        
    }
}


extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return journalEntries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? JournalEntryCell else {
            fatalError("couldt dequeue to the Imagecell..")
        }
        
        let cellEntry = journalEntries[indexPath.row]
        
        cell.configureCell(journalEntry: cellEntry)
        
        //MARK: question why is the self of the custom delegate called here. and not in the viewDidLoad
        // we assign the delegate from the custom cell to the cell itself so it knows what it is looking for.
        cell.JournalEntryEditButtonDelegateReference = self
        // this is where the delegate should look for changes? right?
        
        return cell
    }
    
}
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize: CGSize = UIScreen.main.bounds.size
        let itemWidth: CGFloat = screenSize.width * 0.8// this is 80% of the device
        let itemHeight: CGFloat = screenSize.height * 0.4
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // need index
        let index = indexPath.row
        
        guard let dv = storyboard?.instantiateViewController(identifier: "DetailController") as? DetailController else {
              fatalError("couldnt access DetailController")
          }
        
        let selectedEntry = journalEntries[index]
        
          
          dv.givenJournaEntry = selectedEntry
          
          // deactivivates the dismiss feature when presenting modally
          dv.isModalInPresentation = true

          present(dv, animated: true)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: WHY ARE THESE NEEDED???
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //MARK: what does this do
        // after the image is selected the picker controller will be dismissed.
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // what are we doing here??? - once the user selects a photo from their library we gain access to it inside of here and we want to guard that it is an actual image they chose.
        // taking the selected image that the user choose from the picker and assgin
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            // photo library is automatically a UIImagePickerController.. 
            print("image selection not found. ")
            return
        }
    
        // assigns the data from image which is retrieved from above into the uploaded..
        uploadedPhoto = image
        
        
        // without the dissmis this controller will still show and I will not be able to segue
        dismiss(animated: true)
        // after the controller dimisses I would like for the detail controller to show
        appendNewEntry()
        // want it to segue to the other view controller


    }
    
}

// MARK: question 4:
extension UIImage {
    func resizeImage(width: CGFloat, height: CGFloat) -> UIImage{
        
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}


// want the call the custom delegate protcol here to change the seleted journal entry 
extension ViewController: EditJournalEntryDelegate{
    
    func editEntry(oldEntry: JournalModel, newEntry: JournalModel) {
        let indexLocation = journalEntries.firstIndex(of: oldEntry)!
        
        journalEntries.remove(at: indexLocation)
        journalEntries.insert(newEntry, at: indexLocation)
       // dp.update
    }
    
}
