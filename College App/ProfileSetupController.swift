//
//  ViewController.swift
//  College App
//
//  Created by Jonathan Damico on 7/20/17.
//  Copyright © 2017 Jonathan Damico. All rights reserved.
//

import UIKit
import Firebase

class ProfileSetupController: UIViewController {
	@IBOutlet weak var selectCollegeStackView: UIStackView!
	@IBOutlet weak var firstNameTextField: UITextField!
	@IBOutlet weak var lastNameTextField: UITextField!
	@IBOutlet weak var dateOfBirthTextField: UITextField!
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var selectCollegeTextField: UITextField!
	
	var currentSchool : School? = nil
	
	var isProspectiveStudent = false
	
	func selectCollegeBoxSelected(_ sender: Any) {
		print("test")
		self.performSegue(withIdentifier: "showCollegeSearchTableViewController", sender: self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if isProspectiveStudent {
			self.selectCollegeStackView.isHidden = true
		} else {
			selectCollegeTextField.addTarget(self, action: #selector(selectCollegeBoxSelected(_:)), for: .touchDown)
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func submitButtonTapped(_ sender: Any) {
		
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
		
		guard let firstName = firstNameTextField.text else {
			firstNameTextField.layer.borderColor = UIColor.red.cgColor
			firstNameTextField.layer.borderWidth = 1.0
			return
		}
		
		guard let lastName = lastNameTextField.text else {
			lastNameTextField.layer.borderColor = UIColor.red.cgColor
			lastNameTextField.layer.borderWidth = 1.0
			return
		}
		
		guard let currentSchool = self.currentSchool else {
			selectCollegeTextField.layer.borderColor = UIColor.red.cgColor
			selectCollegeTextField.layer.borderWidth = 1.0
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
		
		if firstName == "" {
			firstNameTextField.layer.borderColor = UIColor.red.cgColor
			firstNameTextField.layer.borderWidth = 1.0
			hasError = true
		}
		
		if lastName == "" {
			lastNameTextField.layer.borderColor = UIColor.red.cgColor
			lastNameTextField.layer.borderWidth = 1.0
			hasError = true
		}
		
		if hasError {
			return
		}
		
		Auth.auth().createUser(withEmail: email, password: password) { (newUser, error) in
			if let newUser = newUser {
				var attrs = ["firstName": firstName,
				             "lastName": lastName]
				if !self.isProspectiveStudent {
					attrs["college"] = currentSchool.UID
				}
				let userRef = Database.database().reference().child("users").child(newUser.uid);
				userRef.setValue(attrs) { (error, ref) in
					if let error = error {
						assertionFailure(error.localizedDescription)
						return
					}
					userRef.observeSingleEvent(of: .value, with: { (snapshot) in
						if let user = User(snapshot:snapshot) {
							User.setCurrent(user, writeToUserDefaults: true)
						}
						if self.isProspectiveStudent {
							self.performSegue(withIdentifier: "showProspectiveStudentHomeViewControllerFromProfileSetupViewController", sender: self)
						} else {
							self.performSegue(withIdentifier: "showCollegeStudentHomeViewControllerFromProfileSetupViewController", sender: self)
						}
					})
				}
			}
		}
	}
	
	@IBAction func unwindToProfileSetupController(_ segue: UIStoryboardSegue) {
		self.selectCollegeTextField.text = currentSchool?.name
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if(segue.identifier == "showCollegeSearchTableViewController") {
			let collegeSearchTableViewController = segue.destination as! CollegeSearchTableViewController
			collegeSearchTableViewController.destinationIsAccountSetup = true
		}
	}
}

