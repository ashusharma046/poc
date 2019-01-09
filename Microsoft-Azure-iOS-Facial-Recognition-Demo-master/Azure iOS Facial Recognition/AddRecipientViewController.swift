//
//  AddRecipientViewController.swift
//  USBPOC
//
//  Created by Ashu Sharma 3 on 1/9/19.
//  Copyright © 2019 Alejandro Cotilla. All rights reserved.
//

import UIKit
import Contacts
class AddRecipientViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        contact.familyName = "Family Name"
        contact.givenName = nameField.text ?? ""
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
    
    
    
}
