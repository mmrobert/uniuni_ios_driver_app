//
//  LoginViewController.swift
//  Uniuni_Driver
//
//  Created by Boqian Cheng on 2022-06-14.
//

import Foundation

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        
        self.createBtn()
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
             loginBtn.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 300)]
        )
    }
    
    @objc
    private func loginAction() {
        let tabbarVC = TabBarController()
        tabbarVC.modalPresentationStyle = .fullScreen
        
        self.present(tabbarVC, animated: false)
    }
}
