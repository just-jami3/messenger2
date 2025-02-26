//
//  LoginViewController.swift
//  Messenger
//
//  Created by Jamie French on 05/10/2020.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    //initiates scroll view
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    // add logo
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
        
    }()
    // email text box
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address"
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    // password text box constructor
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password"
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    // login button constructor
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    //main func to run everything from
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log In"
        self.view.backgroundColor = UIColor.white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        loginButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        //add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        
        
    }
    //layout constructor
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width/2
        imageView.frame = CGRect (x: (scrollView.width-size)/2,
                                  y: 20,
                                  width: size,
                                  height: size)
        emailField.frame = CGRect (x: 30,
                                   y: imageView.bottom + 10,
                                   width: scrollView.width-60,
                                   height: 52)
        passwordField.frame = CGRect (x: 30,
                                      y: emailField.bottom + 10,
                                      width: scrollView.width-60,
                                      height: 52)
        loginButton.frame = CGRect (x: 30,
                                    y: passwordField.bottom + 10,
                                    width: scrollView.width-60,
                                    height: 52)
        
        
    }
    // text validation
    @objc private func loginButtonTapped() {
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty, password.count > 6 else {
            alertUserLoginError()
            return
            
        }
        spinner.show(in: view)
        
        //firebase login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self]authResults, error in
            
            guard let strongSelf = self else{
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
        guard let result = authResults, error == nil else {
            print("failed to log user in with email \(email)")
            return
        }

        
        let user = result.user
            
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            DatabaseManager.shared.getDataFor(path: safeEmail, completion: { result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                          let firstName = userData["first_name"] as? String,
                          let lastName = userData["last_name"] as? String else {
                        return
                    }
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")

                case .failure(let error):
                    print ("failed to read data with error \(error)")
                }
            })
            
            // saves the users email to easily quiery photo from firebase
            UserDefaults.standard.set(email, forKey: "email")
            
            print("user logged in: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    //validation to check if all inputs are correct
    func alertUserLoginError() {
        let  alert = UIAlertController(title: "whoops",
                                       message: "please enter all info to log in",
                                       preferredStyle: .alert)
        alert.addAction (UIAlertAction(title:"Dissmiss",
                                       style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    //links create acc button to registerviewcontroller
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
//lets you skip to the next text box field by pressing done
extension LoginViewController: UITextFieldDelegate {
    func UITextFieldShouldReturn( textFeild: UITextField) -> Bool {
        if textFeild == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textFeild == passwordField {
            loginButtonTapped()
        }
        return true
    }
}
