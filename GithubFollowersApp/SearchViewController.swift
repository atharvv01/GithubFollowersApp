//
//  SearchViewController.swift
//  GithubFollowersApp
//
//  Created by E5000866 on 19/06/24.
//

import UIKit

class SearchViewController: UIViewController {

    let logoImageView = UIImageView()
    let usernameTextField = GFTextField()
    let callToActionButton = GFButton(backgroundColour: .systemGreen, title: "Get Followers")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLogoImageView()
        configureTextField()
        configureCallToActionButton()
    }
    
    //here for this particular screen we dont want navigation bar , now we could have done it in viewDidLoad,
    //but it is only called once and viewWillAppear is called every time view appears
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    func configureLogoImageView(){
        view.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints =  false
        logoImageView.image = UIImage(named: "gh-logo")!
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo:view.safeAreaLayoutGuide.topAnchor , constant: 80),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 200),
            logoImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    func configureTextField(){
        view.addSubview(usernameTextField)

        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo:logoImageView.bottomAnchor , constant: 48),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
        
    }
    
    
    func configureCallToActionButton(){
        view.addSubview(callToActionButton)

        NSLayoutConstraint.activate([
            callToActionButton.bottomAnchor.constraint(equalTo:view.safeAreaLayoutGuide.bottomAnchor , constant: -50),
            callToActionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            callToActionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            callToActionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
    }
    
    
}
