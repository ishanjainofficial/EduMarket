//AUTHENTICATION CODE

import UIKit
import Firebase
import SVProgressHUD
import NVActivityIndicatorView
import SwiftPhoneNumberFormatter
import Alertify
import FBSDKLoginKit
import FBSDKCoreKit

class Authentication: UIViewController, UITextFieldDelegate {
    
    
    struct Groups: Codable {
        let name:String
    }
    
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var haveAccountButton: UIButton!
    @IBOutlet weak var noAccountButton: UIButton!
    
    @IBOutlet weak var registrationView: UIView!
    @IBOutlet weak var registrationViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: PhoneFormattedTextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var termsSwitch: UISwitch!
    
    @IBOutlet weak var loginViewHeight: NSLayoutConstraint!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailLoginTextField: UITextField!
    @IBOutlet weak var passwordLoginTextField: UITextField!
    
    var confirm = false
    
    let terms = Terms()
    
    //Firebase Database Reference Creation
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        //Firebase Database Reference Setup
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        phoneTextField.delegate = self
        passwordTextField.delegate = self
        confirmTextField.delegate = self
        
        emailLoginTextField.delegate = self
        passwordLoginTextField.delegate = self
        
        getStartedButton.layer.cornerRadius = 10
        registrationView.layer.cornerRadius = 10
        loginView.layer.cornerRadius = 10
        createAccountButton.layer.cornerRadius = 10
        createAccountButton.isHidden = true
        loginButton.layer.cornerRadius = 10
        loginButton.isHidden = true
        haveAccountButton.isHidden = true
        noAccountButton.isHidden = true
        registrationViewHeight.constant = 0
        loginViewHeight.constant = 0
        
        ref = Database.database().reference()
        
        phoneTextField.config.defaultConfiguration = PhoneFormat(defaultPhoneFormat: "+ # (###) ###-####")
    }
    
    @IBAction func displayTerms(_ sender: Any) {
        //Display terms here
        showAlertView(title: "Terms and Conditions", message: terms.terms_conditions)
    }
    
    
    @IBAction func getStarted(_ sender: UIButton) {
        Alertify.ActionSheet(title: "Authenticate", message: "Register via Facebook or Sign In with an Existing Account\nPlease select 'Sign In' or 'Register'")
            .action(.default("Register"))
            .action(.default("Sign In"))
            .action(.cancel("Cancel"))
            
            .finally { (action, index) in
                if action.style == .cancel {
                    return
                }else if action.title == "Register" {
                    //AUTHENTICATE WITH FACEBOOK
                    
                    
                    
                    UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                        self.registrationViewHeight.constant = self.view.frame.height - (self.view.safeAreaInsets.top + 180)
                        self.view.layoutIfNeeded()
                    }) { (finished) in
                        //Execute once animation finished
                        self.showAlertView(title: "Success!", message: "You have been succesfully authenticated with Facebook. Please continue your registration to fully authenticate yourself.")
                        
                        self.nameTextField.text = ""
                        self.emailTextField.text = ""
                        self.phoneTextField.text = ""
                        
                        self.createAccountButton.isHidden = false
                        self.haveAccountButton.isHidden = false
                    }
                    
                    
                }else if action.title == "Sign In" {
                    UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                        self.loginViewHeight.constant = self.view.frame.height - (self.view.safeAreaInsets.top + 180)
                        self.view.layoutIfNeeded()
                    }) { (finished) in
                        //Execute once animation finished
                        self.noAccountButton.isHidden = false
                        self.loginButton.isHidden = false
                    }
                }
            }
            .show(on: self, completion: nil)
        
    }
    
    @IBAction func confirmed(_ sender: Any) {
        if termsSwitch.isOn {
            confirm = true
        }
        else {
            confirm = false
        }
    }
    
    @IBAction func createAccount(_ sender: Any) {
        //EMAIL VALIDATION
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        
        let validateEmail = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let emailResult = validateEmail.evaluate(with: emailTextField.text)
        
        //BLUR VIEW
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.3
        view.addSubview(blurEffectView)
        
        
        //ACTIVITY INDICATOR
        let activtityIndicatorType = NVActivityIndicatorType.audioEqualizer
        
        
        let xAxis = self.view.center.x
        let yAxis = self.view.center.y
        
        let frame = CGRect(x: (xAxis), y: (yAxis), width: 60, height: 60)
        
        let activityIndicatorColor = UIColor(red: 89, green: 66, blue: 244, alpha: 1)
        
        let activityFrame = NVActivityIndicatorView(frame: frame, type: activtityIndicatorType, color: activityIndicatorColor, padding: 1)
        
        activityFrame.center.x = view.center.x
        activityFrame.center.y = view.center.y
        
        view.addSubview(activityFrame)
        
        activityFrame.startAnimating()
        
        if nameTextField.text! == "" || emailTextField.text! == "" || passwordTextField.text! == "" || confirmTextField.text! == "" {
            activityFrame.stopAnimating()
            blurEffectView.removeFromSuperview()
            
            self.showAlert(message: "You are missing some credentials!")
        }else if passwordTextField.text != confirmTextField.text! {
            activityFrame.stopAnimating()
            blurEffectView.removeFromSuperview()

            self.showAlert(message: "Your passwords do not match.")
            
        }else if emailResult == false {
            activityFrame.stopAnimating()
            blurEffectView.removeFromSuperview()
            
            self.showAlert(message: "Your email address is not valid")
        }else if phoneTextField.text!.count < 18 {
            activityFrame.stopAnimating()
            blurEffectView.removeFromSuperview()
            
            self.showAlert(message: "Your phone number is not valid")
        }else if Reachability.isConnectedToNetwork() == false {
            activityFrame.stopAnimating()
            blurEffectView.removeFromSuperview()
            
            self.showAlert(message: "There seems to be a network issue")
        }else if confirm != true {
            activityFrame.stopAnimating()
            blurEffectView.removeFromSuperview()

            self.showAlert(message: "Please confirm to the Terms of Conditions")
        }else if passwordTextField.text!.count < 8 {
            activityFrame.stopAnimating()
            blurEffectView.removeFromSuperview()

            self.showAlert(message: "Your password must contain at least 8 characters!")
        }else {
            let email = emailTextField.text!
            let password = passwordTextField.text!
            
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if (error != nil) {
                    activityFrame.stopAnimating()
                    blurEffectView.removeFromSuperview()

                    self.showAlert(message: "There was an error while creating your account.")
                }else {
                    let currentUserID = Auth.auth().currentUser?.uid
                    self.ref.child("users").child(currentUserID!).setValue(["full_name": self.nameTextField.text!, "email": self.emailTextField.text!, "phone": self.phoneTextField.text!, "password": self.passwordTextField.text!, "accept_terms": self.confirm])
                    
                    activityFrame.stopAnimating()
                    blurEffectView.removeFromSuperview()
                    
                    UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                        self.registrationViewHeight.constant = 0
                        self.createAccountButton.isHidden = true
                        self.haveAccountButton.isHidden = true
                        self.view.layoutIfNeeded()
                    }) { (finished) in
                        //Execute once animation finished
                        
                        self.presentViewController()
                    }
                }
            }
        }
    }
    
    @IBAction func login(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            self.registrationViewHeight.constant = 0
            self.createAccountButton.isHidden = true
            self.haveAccountButton.isHidden = true
            self.noAccountButton.isHidden = false
            self.view.layoutIfNeeded()
        }) { (finished) in
            //Execute once animation finished
            UIView.animate(withDuration: 0.25, animations: {
                self.loginViewHeight.constant = self.view.frame.height - (self.view.safeAreaInsets.top + 180)
                self.loginButton.isHidden = false
                self.view.layoutIfNeeded()
            }, completion: { (finished) in
                //Execute once animation is finished
            })
        }
    }
    @IBAction func noAccount(_ sender: Any) {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            self.loginViewHeight.constant = 0
            self.registrationViewHeight.constant = 0
            
            self.noAccountButton.isHidden = true
            self.view.layoutIfNeeded()
        }) { (finished) in
            //Execute once animation finished
            UIView.animate(withDuration: 0.25, animations: {
                
                self.createAccountButton.isHidden = true
                self.loginButton.isHidden = true
                self.view.layoutIfNeeded()
            }, completion: { (finished) in
                //Execute once animation is finished
            })
        }
    }
    
    @IBAction func loginUser(_ sender: Any) {
        //BLUR VIEW
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.3
        view.addSubview(blurEffectView)
        
        
        //ACTIVITY INDICATOR
        let activtityIndicatorType = NVActivityIndicatorType.audioEqualizer
        
        
        let xAxis = self.view.center.x
        let yAxis = self.view.center.y
        
        let frame = CGRect(x: (xAxis), y: (yAxis), width: 60, height: 60)
        
        let activityIndicatorColor = UIColor(red: 89, green: 66, blue: 244, alpha: 1)
        
        let activityFrame = NVActivityIndicatorView(frame: frame, type: activtityIndicatorType, color: activityIndicatorColor, padding: 1)
        
        activityFrame.center.x = view.center.x
        activityFrame.center.y = view.center.y
        
        view.addSubview(activityFrame)
        
        activityFrame.startAnimating()

        Auth.auth().signIn(withEmail: emailLoginTextField.text!, password: passwordLoginTextField.text!) { (user, error) in
            if (error != nil) {
                activityFrame.stopAnimating()
                blurEffectView.removeFromSuperview()
                
                self.showAlert(message: "There was an error while signing you in!")
            }else {
                self.presentViewController()
                activityFrame.stopAnimating()
                blurEffectView.removeFromSuperview()

            }
        }
    }
    
    func showAlert(message: String) {
        SVProgressHUD.showError(withStatus: message)
    }
    
    func showAlertView(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "authenticated")
        self.present(controller, animated: true, completion: nil)
    }
    
    
    //AUTHENTICATE WITH FACEBOOK
    
    // Once the button is clicked, show the login dialog
    func authenticateWithFacebook() {
        
    }
}
