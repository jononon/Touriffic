//
//  ViewController.swift
//  College App
//
//  Created by Jonathan Damico on 7/20/17.
//  Copyright © 2017 Jonathan Damico. All rights reserved.
//

import UIKit

class WelcomeScreen: UIViewController {
	
	@IBOutlet weak var collegeStudentButton: UIButton!
	@IBOutlet weak var prospectiveStudentButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let identifier = segue.identifier {
			if identifier == "Prospective" {
				let destination = segue.destination as! ProfileSetupController
				destination.isProspectiveStudent = true
			} else if identifier == "College" {
				let destination = segue.destination as! ProfileSetupController
				destination.isProspectiveStudent = false
			}
		}
	}
	
	@IBAction func unwindToWelcomeScreen(_ segue: UIStoryboardSegue) {
		
	}
}

