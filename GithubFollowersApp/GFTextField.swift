//
//  GFTextField.swift
//  GithubFollowersApp
//
//  Created by E5000866 on 21/06/24.
//

import UIKit

class GFTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        Configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func Configure() {
        translatesAutoresizingMaskIntoConstraints =  false
        
        layer.cornerRadius = 10
        layer.borderWidth = 2
        layer.borderColor = UIColor.systemGray4.cgColor
        
        //label is kinf of colour that is white in dark mode and black in light mode
        textColor = .label
        //blinking cursor colour
        tintColor = .label
        textAlignment = .center
        font = UIFont.preferredFont(forTextStyle: .title2)
        //this means if someone had very big username , font will shrink to fit in that width
        adjustsFontSizeToFitWidth = true
        minimumFontSize = 12
        backgroundColor = .tertiarySystemBackground
        autocorrectionType = .no
        
        placeholder = "Enter the username"
    }
    
}
