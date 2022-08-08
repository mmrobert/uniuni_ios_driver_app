//
//  LoginViewController.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-06-14.
//

import Foundation

import UIKit

class LoginViewController: UIViewController {
    
    lazy var driverID: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "ID"
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return textField
    }()
    
    private var tokenInput: UITextView = {
        
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.textAlignment = NSTextAlignment.justified
        textView.backgroundColor = UIColor.lightGray198
        
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.textColor = UIColor.black
        
        textView.autocorrectionType = UITextAutocorrectionType.no
        textView.spellCheckingType = UITextSpellCheckingType.no
        
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        
        self.tokenField()
        self.createBtn()
    }
    
    private func tokenField() {
        
        self.view.addSubview(tokenInput)
        NSLayoutConstraint.activate(
            [tokenInput.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
             tokenInput.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
             tokenInput.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 120),
             tokenInput.heightAnchor.constraint(equalToConstant: 160)]
        )
    }
    
    private func createBtn() {
        
        let loginBtn = UIButton()
        loginBtn.backgroundColor = .blue
        loginBtn.setTitle("Login", for: .normal)
        loginBtn.setTitleColor(.red, for: .normal)
        loginBtn.addTarget(self, action: #selector(LoginViewController.loginAction), for: .touchUpInside)
        self.view.addSubview(loginBtn)
        
        loginBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [loginBtn.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 100),
             loginBtn.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -100),
             loginBtn.topAnchor.constraint(equalTo: self.tokenInput.topAnchor, constant: 300)]
        )
    }
    
    @objc
    private func loginAction() {
        let tabbarVC = TabBarController()
        tabbarVC.modalPresentationStyle = .fullScreen
        
        if let token = self.tokenInput.text {
            UserDefaults.standard.set(token, forKey: "tempToken")
        }
        
        self.present(tabbarVC, animated: false)
    }
}
