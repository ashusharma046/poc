//
//  AddRecipientViewController.swift
//  USBPOC
//
//  Created by Ashu Sharma 3 on 1/9/19.
//  Copyright © 2019 Alejandro Cotilla. All rights reserved.
//

import UIKit
import Contacts
class AddRecipientViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var btnSelectImage: UIButton!
    @IBAction func btnSelectImageAction(_ sender: UIButton) {
        openActionSheetForCamera(sender: sender)
    }
    
    var imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self 
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    
    @IBAction func submitButtonTapped() {
        let store = CNContactStore()
        let contact = CNMutableContact()
       // contact.familyName = "Family Name"
        contact.givenName = nameField.text ?? ""
        if (btnSelectImage.imageView?.image != nil){
        let imageData: NSData = UIImagePNGRepresentation(btnSelectImage.imageView?.image ?? UIImage())! as NSData
        contact.imageData = imageData as Data
        }
        let homeEmail = CNLabeledValue(label: CNLabelHome,
                                       value: emailField.text as NSString? ?? "")
        let workEmail = CNLabeledValue(label: CNLabelHome,
                                       value: emailField.text as NSString? ?? "")
        contact.emailAddresses = [homeEmail, workEmail]
        let address = CNMutablePostalAddress()
        address.street = "Sapient sec 144"
        address.city = "Noida"
        address.state = "up"
        address.postalCode = "12345"
        address.country = "india"
        let home = CNLabeledValue<CNPostalAddress>(label:CNLabelHome, value:address)
        contact.postalAddresses = [home]
        
        
        // Save
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier: nil)
        try? store.execute(saveRequest)
        self.navigationController?.popViewController(animated: true)
        
        
        
    }
    
    
    
    
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
        imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
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
