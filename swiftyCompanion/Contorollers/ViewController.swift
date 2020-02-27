//
//  ViewController.swift
//  SwiftyCompanion
//
//  Created by Muamba-nzambi, Moses on 2019/12/20.
//  Copyright © 2019 MuaMoses. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Locksmith

class ViewController: UIViewController {
   
    var auth = Auth()
    var json: JSON?
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        searchButton.isEnabled = false
        activityIndicator.startAnimating()
        auth.searchLogin(searchTextField.text!) { (json, errorMessage) in
            
            self.activityIndicator.stopAnimating()
            if json != nil {
                self.json = json
                self.performSegue(withIdentifier: "segueToProfileVC", sender: self)
            } else {
                let message = errorMessage ?? "Login \(self.searchTextField.text!) doesn't exist"
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            self.searchButton.isEnabled = true
        }
        
    }
    
    @IBAction func searchTextFieldEditingChanged(_ sender: UITextField) {
        if sender.text == " " {
            sender.text = ""
        }
        searchButton.isEnabled = sender.text == "" ? false : true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        searchButton.isEnabled = false
        auth.getToken()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // hides keyboard if user clicks on the background view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToProfileVC" {
            let destination = segue.destination as! ProfileViewController
            destination.json = json
        }
    }
    
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if searchButton.isEnabled {
            searchButton.sendActions(for: .touchUpInside)
        }
        return true
    }
}

