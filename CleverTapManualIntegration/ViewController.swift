//
//  ViewController.swift
//  CleverTapManualIntegration
//
//  Created by Vishal More on 28/11/24.
//

import UIKit
import CleverTapSDK

class ViewController: UIViewController {

    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfIdentity: UITextField!
    @IBOutlet weak var tfPhone: UITextField!
    
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnPushEvent: UIButton!
    
    //var tapRecognizer: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        tapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @IBAction func btnClicked(_ sender: UIButton) {
        
        
        
        switch sender {
        case btnLogin:
            
            let _identity:String? = tfIdentity.text
            let _email:String? = tfEmail.text
            let _phone:String? = tfPhone.text
            
            if _identity?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
                self.showToast(message: "Enter Identity", font: .systemFont(ofSize: 12.0))
                break
            }
            
            let profile: Dictionary<String, AnyObject> = [
                
                "Identity": _identity as AnyObject,                   // String or number
                "Name": "User \(String(describing: _identity))" as AnyObject,
                "Email": _email as AnyObject,              // Email address of the user
                "Phone": _phone as AnyObject,                // Phone (with the country code, starting with +)
                "Gender": "M" as AnyObject,                          // Can be either M or F
                "Age": 28 as AnyObject,                              // Not required if DOB is set
                "Photo": "https://i.ibb.co/RBhV1Rm/michael-dam-m-EZ3-Po-FGs-k-unsplash.jpg" as AnyObject,   // URL to the Image
            // optional fields. controls whether the user will be sent email, push etc.
                "MSG-email": true as AnyObject,                     // Disable email notifications
                "MSG-push": true as AnyObject,                       // Enable push notifications
                "MSG-sms": true as AnyObject,                       // Disable SMS notifications
            ]

            CleverTap.sharedInstance()?.onUserLogin(profile)
            self.showToast(message: "Login Called", font: .systemFont(ofSize: 12.0))
            
            let defaults = UserDefaults.init(suiteName: "group.nativeios")
            defaults?.setValue(_identity, forKey: "identity")
            defaults?.setValue(_email, forKey: "email")
            defaults?.set(true, forKey: "logged_in")
            
            break
        case btnPushEvent:
            
            CleverTap.sharedInstance()?.recordEvent("Blog Article Viewed")
            self.showToast(message: "Event Pushed", font: .systemFont(ofSize: 12.0))
            break
        default:
            break
        }
    }
    
    @objc func handleSingleTap(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func showToast(message : String, font: UIFont) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 125, y: self.view.frame.size.height-100, width: 250, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(1.0)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    
}

