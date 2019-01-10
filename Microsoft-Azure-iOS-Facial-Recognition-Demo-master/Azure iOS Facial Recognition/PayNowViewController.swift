//
//  PayNowViewController.swift
//  USBPOC
//
//  Created by Ashu Sharma 3 on 1/10/19.
//  Copyright © 2019 Alejandro Cotilla. All rights reserved.
//

import UIKit

class PayNowViewController: UIViewController {
    @IBOutlet weak var amountField: UITextField!
    
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
        
        let alert = UIAlertController(title: "Alert", message: "Amount paid successfully", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
           self.navigationController?.popToRootViewController(animated: true)
        }
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
     }
}
