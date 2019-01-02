//
//  ViewController.swift
//  Azure iOS Facial Recognition
//
//  Created by Alejandro Cotilla on 8/14/18.
//  Copyright © 2018 Alejandro Cotilla. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var imagePicker = UIImagePickerController()
    let avatarsSection = 0
    let photosSection = 1
    var selectedPerson : Person? = nil
    
    
    @IBOutlet weak var btnSelectImage: UIButton!
    @IBAction func btnSelectImageAction(_ sender: UIButton) {
        openActionSheetForCamera(sender: sender)
    }
    var persons: [Person] = []
    var photos: [Photo] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ContentManager.shared.load {
            self.persons = ContentManager.shared.persons
            self.photos = ContentManager.shared.photos
            self.collectionView.reloadData()
            
            self.activityIndicator.stopAnimating()
        }
    }
    
    // Re-adjust collection view layout on device rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        flowLayout.invalidateLayout()
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // Avoid selection on the standard photos section
        return indexPath.section == avatarsSection
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        activityIndicator.startAnimating()
        
        let person = persons[indexPath.item]

        // Clear photos section
        self.photos = []
        collectionView.reloadSections([photosSection])
        
        // Disable interactions while finding similar images
        collectionView.isUserInteractionEnabled = false
        
        // Find photos that match the selected avatar
        AzureFaceRecognition.shared.findSimilars(faceId: person.faceId, faceIds: ContentManager.shared.allPhotosFaceIds) { (faceIds) in
            self.photos = ContentManager.shared.photos(withFaceIds: faceIds)
            self.collectionView.reloadSections([self.photosSection])
            self.collectionView.isUserInteractionEnabled = true
            
            self.activityIndicator.stopAnimating()
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // Two sections, avatars and standard photos.
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == avatarsSection {
            return 0//persons.count
        }
        
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCellView
        
        let image = indexPath.section == avatarsSection ? persons[indexPath.item].avatar : photos[indexPath.item].image
        cell.imageView.image = image
        
        cell.type = indexPath.section == avatarsSection ? .round : .square
        
        
        let photo = photos[indexPath.item]
        
        cell.lblPhone.text = photo.phoneNumber.first
        cell.lblEmail.text = photo.email.first
        cell.lblFirstName.text = photo.name
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Calculate cell sizes depending on the screen width and the section.
        
        var itemsPerRow = 1
        if indexPath.section == avatarsSection {
            itemsPerRow = persons.count
        }
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let space = collectionView.frame.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * CGFloat(itemsPerRow - 1)
        let length = floor(space / CGFloat(itemsPerRow))
        
        return CGSize(width: length, height: 120)
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    func openActionSheetForCamera(sender : Any)  {
        
        let actionSheet = UIAlertController(title: "FaceDemo", message: nil, preferredStyle: .actionSheet)
        let actionTake = UIAlertAction(title: "Take Photo", style: .default) { (action) in
            self.openImagePickerController(shouldOpenCamera: true)
        }
        let uploadLibrary = UIAlertAction(title: "Upload from Library", style: .default) { (action) in
            self.openImagePickerController(shouldOpenCamera: false)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        
        actionSheet.addAction(actionTake)
        actionSheet.addAction(uploadLibrary)
        actionSheet.addAction(cancel)
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            actionSheet.popoverPresentationController?.sourceView = sender as? UIView
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func openImagePickerController(shouldOpenCamera : Bool)  {
        
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.currentContext
        imagePicker.delegate = self
        imagePicker.sourceType = shouldOpenCamera ? .camera : .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    //MARK: - UIImagePickerController Delegates
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any])
    {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let resizedImage = self.resizeImage(image: chosenImage, newWidth: 480)
//        let data = UIImagePNGRepresentation(chosenImage) as NSData?
        let data = UIImageJPEGRepresentation(resizedImage, 1.0) as NSData?
        
        
        if let faceId = AzureFaceRecognition.shared.syncDetectFaceIds(imageData: data! as Data).first {
            let person = Person()
            person.faceId = faceId
            person.avatar = chosenImage
            selectedPerson = person
            
            
            AzureFaceRecognition.shared.findSimilars(faceId: person.faceId, faceIds: ContentManager.shared.allPhotosFaceIds) { (faceIds) in
                self.photos = ContentManager.shared.photos(withFaceIds: faceIds)
                self.collectionView.reloadSections([self.photosSection])
                self.collectionView.isUserInteractionEnabled = true
                
                self.activityIndicator.stopAnimating()
            }
        }
        
        
        
        btnSelectImage.setImage(resizedImage, for: .normal)
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
     func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0,width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
