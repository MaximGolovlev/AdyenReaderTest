//
//  Helpers.swift
//  AdyenReaderTest
//
//  Created by Maxim on 09.03.2023.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String? = "Oops :(",
                   message: String?,
                   loginConfigureation: ((UITextField) -> Void)? = nil,
                   passwordConfigureation: ((UITextField) -> Void)? = nil,
                   cancelTitle: String? = "Got it!",
                   cancelHandler: ((String?, String?)-> Void)? = nil,
                   presentCompletion: (()-> Void)? = nil) {
        
        DispatchQueue.main.async { [weak self] in
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            if let config = loginConfigureation {
                alert.addTextField(configurationHandler: config)
            }
            
            if let config = passwordConfigureation {
                alert.addTextField(configurationHandler: config)
            }
            
            let close = UIAlertAction(title: cancelTitle, style: .cancel, handler: { _ in
                let loginText = alert.textFields?[safe: 0]?.text
                let passText = alert.textFields?[safe: 1]?.text
                
                cancelHandler?(loginText, passText)
            })
            
            alert.addAction(close)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self?.present(alert, animated: true, completion: presentCompletion)
            }
        }
    }
    
    func showTwoButtonAlert(title: String?, message: String? = nil,
                            loginConfigureation: ((UITextField) -> Void)? = nil,
                            passwordConfigureation: ((UITextField) -> Void)? = nil,
                            cancelButtonTitle: String? = "Cancel",
                            okButtonTitle: String? = "Ok",
                            cancelHandler: (() -> Void)? = nil,
                            okHandler: ((String?, String?) -> Void)? = nil) {
        
        DispatchQueue.main.async { [weak self] in
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            if let config = loginConfigureation {
                alert.addTextField(configurationHandler: config)
            }
            
            if let config = passwordConfigureation {
                alert.addTextField(configurationHandler: config)
            }
            
            let cancel = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: { _ in
                cancelHandler?()
            })
            alert.addAction(cancel)
            
            let ok = UIAlertAction(title: okButtonTitle, style: .default, handler: { _ in
                let loginText = alert.textFields?[safe: 0]?.text
                let passText = alert.textFields?[safe: 1]?.text
                okHandler?(loginText, passText)
            })
            alert.addAction(ok)
            
            self?.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
}
