//
//  MyProfile.swift
//  EduMarket
//
//  Created by Ishan Jain on 5/25/19.
//  Copyright © 2019 EduMarket. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class MyProfile: UITableViewController {

    var ref: DatabaseReference!
    
    
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phone: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        
        self.title = "My Profile"
        
        SVProgressHUD.show()
        
        if Reachability.isConnectedToNetwork() == false {
            dismiss(animated: true, completion: nil)
            SVProgressHUD.dismiss()
            showAlertView(title: "Oops!", message: "Please connect to a network before you continue.")
        }else {
            retrieveUserInformation()
            SVProgressHUD.dismiss()
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    func retrieveUserInformation() {
        let userID = Auth.auth().currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let name = value?["full_name"] as? String ?? ""
            let email = value?["email"] as? String ?? ""
            let phone = value?["phone"] as? String ?? ""
            
            self.name.text = name
            self.email.text = email
            self.phone.text = phone
            
            // ...
        }) { (error) in
            self.showAlertView(title: "Oops!", message: error.localizedDescription)
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        SVProgressHUD.show()
        try! Auth.auth().signOut()
        logoutNavigation()
        SVProgressHUD.dismiss()
    }
    
    func logoutNavigation() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "logout")
        self.present(controller, animated: true, completion: nil)
    }
    
    func showAlertView(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

}
