//
//  SignUpController.swift
//  WhereU.
//
//  Created by be RUPU on 16/12/21.
//

import UIKit
import Firebase

class SignUpController: UIViewController{
    
    //MARK: - Properties
    
    var imageURL : String?
    
    let profileImageButton : UIButton = {
        let pi = UIButton(type: .system)
        pi.layer.borderWidth = 5
        pi.layer.borderColor = UIColor.black.cgColor
        pi.layer.masksToBounds = true
        pi.contentMode = .scaleAspectFill
        pi.addTarget(self, action: #selector(handleProfileImge), for: .touchUpInside)
        return pi
    }()

    private let userNameTextField : UITextField = {
       let textField = UITextField()
        textField.placeholder = "Enter your username"
        textField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return textField
    }()
    
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
    
    private let signInButton : UIButton = {
        let lb = UIButton(type: .system)
        lb.setTitle("SignIn", for: .normal)
        lb.backgroundColor = .gray
        lb.tintColor = .cyan
        lb.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
        lb.layer.cornerRadius = 5
        lb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        lb.setTitleColor(.white, for: .normal)
        lb.isEnabled = false
        return lb
    }()
    
    private let alreadyHaveAccount: UIButton = {
       let button = UIButton()
        
        let attributedText = NSMutableAttributedString(string: "Already ave a account?", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        attributedText.append(NSAttributedString(string: " LogIn", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.darkGray]))
        
        button.setAttributedTitle(attributedText, for: .normal)
        
        button.addTarget(self, action: #selector(handlealreadyHaveAccount), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        signInDesign()
        
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - Selector
    
    @objc func handleProfileImge(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && userNameTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            signInButton.isEnabled = true
            signInButton.backgroundColor = UIColor.blue
        } else {
            signInButton.isEnabled = false
            signInButton.backgroundColor = UIColor.gray
        }
    }
  
    
    @objc func handleSignIn(){
        print("sigIn")
    
        guard let username = userNameTextField.text, username.count > 0 else {return}
        guard let email = emailTextField.text, email.count > username.count else {return}
        guard let password = passwordTextField.text, password.count > 0 else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) { [self] (result, error) in
            
            if error != nil {
                print("failed to create user")
            }
            
            guard let currentUser = result?.user.uid else {return}
            
            let storageRef = Storage.storage().reference().child("Profile Images").child(currentUser)
            
            
            guard let profileImage = profileImageButton.imageView?.image?.jpegData(compressionQuality: 0.3) else {return}
            
            
            storageRef.putData(profileImage, metadata: nil) { (metaData, err) in
                
                if error != nil{
                    print("failed to upload image")
                }
                
                storageRef.downloadURL { (url, err) in
                    if error != nil{
                        print("failed to upload image")
                    }
                    
                    guard let url = url else {return}
                    
                    imageURL = url.absoluteString
                    
                    let values = ["username": username, "uid": currentUser, "profileImgaeUrl": imageURL]
                    
                    let databaseRef = Database.database().reference()
                    
                    databaseRef.child("Users").childByAutoId().updateChildValues(values as [AnyHashable : Any]) { (err, ref) in
                        
                        if err != nil {
                            print("failed to update data to firebase :\(String(describing: err))")
                        }else {
                            print("Data updated successfully")
                        }
                        
                    }
                    
                }
        }
    
            let viewController = HomeController()
            let navController = UINavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        }
    
    }
    
    @objc func handlealreadyHaveAccount(){
        navigationController?.pushViewController(LogInController(), animated: true)
    }

    
    
    func signInDesign(){
        
        view.addSubview(profileImageButton)
        
        profileImageButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 120, height: 120)
        
        profileImageButton.centerX(inView: view)
        
        profileImageButton.layer.cornerRadius = 120/2
        
        let stack = UIStackView(arrangedSubviews: [userNameTextField,emailTextField,passwordTextField,signInButton])
        stack.axis = .vertical
        stack.spacing = 10
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        stack.anchor(top: profileImageButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 80, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 300, height: 300)
        
        
        view.addSubview(alreadyHaveAccount)
        
        alreadyHaveAccount.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 102, paddingRight: 12, width: 0, height: 20)
        
    }
    
    
}

//MARK: - ImagePickerController
extension SignUpController: UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let editedImage = info[.editedImage] as? UIImage {
            profileImageButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
            
            
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
            
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

