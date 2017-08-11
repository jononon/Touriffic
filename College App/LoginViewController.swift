//
//  LoginViewController.swift
//  College App
//
//  Created by Jonathan Damico on 8/9/17.
//  Copyright © 2017 Jonathan Damico. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController : UIViewController {
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	
	@IBAction func onFormSubmit(_ sender: Any) {
		
		guard let email = emailTextField.text else {
			emailTextField.layer.borderColor = UIColor.red.cgColor
			emailTextField.layer.borderWidth = 1.0
			return
		}
		
		guard let password = passwordTextField.text else {
			passwordTextField.layer.borderColor = UIColor.red.cgColor
			passwordTextField.layer.borderWidth = 1.0
			return
		}
		
		var hasError = false;
		if email == "" {
			emailTextField.layer.borderColor = UIColor.red.cgColor
			emailTextField.layer.borderWidth = 1.0
			hasError = true
		}
		
		if password == "" {
			passwordTextField.layer.borderColor = UIColor.red.cgColor
			passwordTextField.layer.borderWidth = 1.0
			hasError = true
		}
		
		if hasError {
			return
		}
		
		Auth.auth().signIn(withEmail: email, password: password) { (newUser, error) in
			
			if let _ = error {
				self.passwordTextField.layer.borderColor = UIColor.red.cgColor
				self.passwordTextField.layer.borderWidth = 1.0
				
				self.emailTextField.layer.borderColor = UIColor.red.cgColor
				self.emailTextField.layer.borderWidth = 1.0
				return
			} else if let newUser = newUser {
				let uid = newUser.uid
				let ref = Database.database().reference().child("users").child(uid)
				ref.observeSingleEvent(of: .value, with: {(snapshot) in
					if let user = User(snapshot:snapshot) {
						User.setCurrent(user, writeToUserDefaults: true)
					}
					let value = snapshot.value as? NSDictionary
					let college = value?["college"]
					if(college == nil) {
						self.performSegue(withIdentifier: "showProspectiveStudentHomeViewControllerFromLoginViewController", sender: self)
					} else {
						self.performSegue(withIdentifier: "showCollegeStudentHomeViewControllerFromLoginViewController", sender: self)
					}
				}) {(error) in
					print(error.localizedDescription)
				}
			}
		}
	}
}
