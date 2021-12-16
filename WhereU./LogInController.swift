//
//  ViewController.swift
//  WhereU.
//
//  Created by be RUPU on 4/12/21.
//

import UIKit

class LogInController: UIViewController {
    
    
    private let emailTextField : UITextField = {
        let et = UITextField()
        et.placeholder = "Enter your mail"
        et.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return et
    }()
    
    
    private let passwordTextField : UITextField = {
        let pt = UITextField()
        pt.placeholder = "Enter your password"
        pt.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return pt
    }()
    
    private let loginButton : UIButton = {
        let lb = UIButton(type: .system)
        lb.setTitle("Login", for: .normal)
        lb.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        lb.backgroundColor = UIColor.gray
        lb.layer.cornerRadius = 5
        lb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        lb.setTitleColor(.white, for: .normal)
        lb.isEnabled = false
        return lb
    }()
    
    private let dontHaveAccount : UIButton = {
        let button = UIButton(type: .system)

        button.addTarget(self, action: #selector(handleDontHaveAccount), for: .touchUpInside)
        let attributedText = NSMutableAttributedString(string: "Don't have an account?", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        attributedText.append(NSAttributedString(string: " SignIn", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.darkGray]))
        
        button.setAttributedTitle(attributedText, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        loginDesign()
        
    }
    
    @objc fileprivate func handleLogin(){
        print("Log in works")
        
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil{
                print("failed to logIn: \(String(describing: error))")
            }
            
            print("successfully logged in")
            
            let navController = UINavigationController(rootViewController: HomeController())
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
            
        }

    }
    
    //MARK: - Selector
    
    @objc func handleDontHaveAccount(){
       
        print("sign up")
        
        let navController = UINavigationController(rootViewController: SignUpController())
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
        
    }
    
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            loginButton.isEnabled = true
            loginButton.backgroundColor = UIColor.blue
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor.gray
        }
    }
    
    func loginDesign(){
        let stack = UIStackView(arrangedSubviews: [emailTextField,passwordTextField,loginButton])
        stack.axis = .vertical
        stack.spacing = 10
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        stack.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 140, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 200, height: 200)
       
        
        view.addSubview(dontHaveAccount)
        dontHaveAccount.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 102, paddingRight: 12, width: 0, height: 20)
        
    }
    
}


