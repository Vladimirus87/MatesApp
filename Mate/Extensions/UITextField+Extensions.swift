//
//  UITextField+Extensions.swift
//  Mate
//
//  Created by Vladimirus on 17.12.2021.
//

import UIKit


extension UITextField {
    
    var isEmpty: Bool {
        return text?.isEmpty == true || text == nil
    }
    
    enum TextFieldStyle {
        case error
        case success
        case simple
        
        var color: UIColor {
            switch self {
            case .error:
                return UIColor(named: "red")!
            case .success:
                return UIColor(named: "green")!
            case .simple:
                return UIColor(named: "greyBlue")!
            }
        }
    }
     
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setBorder(style: TextFieldStyle = .simple) -> Void {
        self.layer.borderColor = style.color.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
    }
    
    
    func showMessage(_ message: String, style: TextFieldStyle = .error) {
        let errorLbl = UILabel()
        errorLbl.backgroundColor = .clear
        errorLbl.numberOfLines = 1
        errorLbl.text = message
        errorLbl.textColor = style.color
        errorLbl.textAlignment = .left
        errorLbl.font = UIFont.systemFont(ofSize: 14)
        
        self.addSubview(errorLbl)
        self.bringSubviewToFront(errorLbl)
        
        errorLbl.translatesAutoresizingMaskIntoConstraints = false
        errorLbl.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        errorLbl.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        errorLbl.topAnchor.constraint(equalTo: self.topAnchor, constant: frame.height).isActive = true
        errorLbl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        self.layer.borderColor = style.color.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.layer.borderColor = TextFieldStyle.simple.color.cgColor
            errorLbl.removeFromSuperview()
        }

    }
    
    func checkEmpty()-> Bool {
        let isEmpty = text?.isEmpty == true
        if isEmpty {
            showMessage("Поле не должно быть пустым", style: .error)
        }
        return isEmpty
    }
    
    
    var value: String? {
        if let _text = text?.trimmingCharacters(in: .whitespaces), !_text.isEmpty {
            return text
        } else {
            return nil
        }
    }
}


