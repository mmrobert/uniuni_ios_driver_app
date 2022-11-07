//
//  LoginViewController.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-06-14.
//

import Foundation

import UIKit
import Combine

class LoginViewController: UIViewController {
    
    lazy var driverIDInput: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Driver ID"
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return textField
    }()
    
    private var passwordInput: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Password"
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return textField
    }()
    
    private var disposables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        
        self.setupUI()
        self.createBtn()
    }
    
    private func setupUI() {
        
        self.view.addSubview(driverIDInput)
        NSLayoutConstraint.activate(
            [driverIDInput.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
             driverIDInput.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -50),
             driverIDInput.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 120)]
        )
        
        self.view.addSubview(passwordInput)
        NSLayoutConstraint.activate(
            [passwordInput.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
             passwordInput.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -50),
             passwordInput.topAnchor.constraint(equalTo: driverIDInput.bottomAnchor, constant: 30)]
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
             loginBtn.topAnchor.constraint(equalTo: self.passwordInput.bottomAnchor, constant: 80)]
        )
    }
    
    @objc
    private func loginAction() {
        let tabbarVC = TabBarController()
        tabbarVC.modalPresentationStyle = .fullScreen
        
        if let driverID = Int(driverIDInput.text ?? ""), let pw = passwordInput.text {
            NetworkService.shared.login(driverID: driverID, pw: pw)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { value in
                    switch value {
                    case .failure( _):
                        break
                    case .finished:
                        break
                    }
                }, receiveValue: { [weak self] login in
                    guard let token = login.biz_data?.access_token else { return }
                    AppConfigurator.shared.setDriverID(driverID: driverID)
                    AppConfigurator.shared.setToken(token: token)
                    self?.present(tabbarVC, animated: false)
                })
                .store(in: &disposables)
        }
    }
}
