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

    // this isnt working
    var imagePickerController = UIImagePickerController()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    
    //MARK: question 6
    // why is it an optional when in scheduler we banged it.
    // why not the generic ... why the model??
    let dataPersistence = DataPersistence<ImageObject>(filename: "photos.plist")
    
    private var allPhotos = [ImageObject]()
    
    private var uploadedPhoto: UIImage? {
        didSet{
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        
        imagePickerController.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
        loadAllImages()
        
        //mainControllerDelegate.delegate = self
    }
    
    private func loadAllImages() {
        do {
            // give the emtpy photos array photos
           try allPhotos = dataPersistence.loadPhotos()
        } catch {
            print("here is the error: \(error)")
        }
    }
    
    
    private func appendNewPhoto() {
        guard let photo = uploadedPhoto else {
            print("the uploaded photo cant be accessed.")
            return
        }
        
//want to ensure the size of the photo is what is needed.
        let size = UIScreen.main.bounds.size // this gives access to the size
        
        // what does this say??
        // Does this make the shape of a rectangle??
        let rect = AVMakeRect(aspectRatio: photo.size, insideRect: CGRect(origin: CGPoint.zero, size: size))
        
        //what is this for??
        let resizeImage = photo.resizeImage(width: rect.size.width, height: rect.size.height)
        
        guard let imageData = resizeImage.jpegData(compressionQuality: 1.0) else {
            // MARK:question 5. why 1.0 what does it stand for
            return
        }
        
        //image object with the selected image
            // MARK: the below code is not working and I dont understand why..
        let imageObject = ImageObject(imageData: imageData, date: Date())
        
// appending into the empty variable of ImageObjects above
        
        allPhotos.insert(imageObject, at: 0)
        
        // the place for insertion
        let indexPath = IndexPath(row: 0, section: 0)
        
        //the location to insert the items at
        collectionView.insertItems(at: [indexPath])
        
        // persist the object to documents directory
    
        do{
            try dataPersistence.createPhotos(aPhoto: imageObject)
        }catch{
            print("The error is \(error)")
        }
        
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
extension ViewController: ImageCellDelegate {
    func didLongPress(_ imageCell: ImageCell) {
        // this cell was selected...
        
        guard let indexPath = collectionView.indexPath(for: imageCell) else {
            return
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
                  [weak self] alertAction in
                  self?.DeletePhoto(indexPath: indexPath)
              }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
    }
    
    private func DeletePhoto(indexPath: IndexPath){
        // when they click delete
        do{
            try dataPersistence.deletePhoto(at: indexPath.row)
            
            allPhotos.remove(at: indexPath.row)
            
            collectionView.deleteItems(at: [indexPath])
        } catch {
            print("error in deleting \(error)")
        }
        
    }
    
    private func didEditPhoto(){
        
        
    }
    
    private func didUpdatePhoto(){
        
        // resave photo..
    }
    
    
}


extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? ImageCell else {
            fatalError("couldt dequeue to the Imagecell..")
        }
        
        let cellImage = allPhotos[indexPath.row]
        cell.configureCell(imageObject: cellImage)
        
        //MARK: question why is the self of the custom delegate called here. and not in the viewDidLoad
        cell.imageDelegateReference = self
        
        return cell
    }
    
}
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxWidth: CGFloat = UIScreen.main.bounds.size.width
        let itemWidth: CGFloat = maxWidth * 0.80 // this is 80% of the device
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: WHY ARE THESE NEEDED???
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //MARK: what does this do?
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // what are we doing here???
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            print("image selection not found. ")
            return
        }
    
        // assigns the data from image which is retrieved from above into the uploaded..
        uploadedPhoto = image
        
        // without the dissmis what WONT happen?/
        dismiss(animated: true)
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
