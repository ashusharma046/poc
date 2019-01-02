//
//  ViewController.swift
//  Azure iOS Facial Recognition
//
//  Created by Alejandro Cotilla on 8/14/18.
//  Copyright © 2018 Alejandro Cotilla. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let avatarsSection = 0
    let photosSection = 1
    
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
            return persons.count
        }
        
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCellView
        
        let image = indexPath.section == avatarsSection ? persons[indexPath.item].avatar : photos[indexPath.item].image
        cell.imageView.image = image
        
        cell.type = indexPath.section == avatarsSection ? .round : .square
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Calculate cell sizes depending on the screen width and the section.
        
        var itemsPerRow = 3
        if indexPath.section == avatarsSection {
            itemsPerRow = persons.count
        }
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let space = collectionView.frame.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * CGFloat(itemsPerRow - 1)
        let length = floor(space / CGFloat(itemsPerRow))
        
        return CGSize(width: length, height: length)
    }
    
}

