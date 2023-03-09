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
                   actionTitle: String? = "Got it!",
                   actionHandler: (() -> Void)? = nil,
                   cancelTitle: String? = "Got it!",
                   cancelHandler: (()-> Void)? = nil,
                   presentCompletion: (()-> Void)? = nil) {
        
        DispatchQueue.main.async { [weak self] in
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            if let actionHandler = actionHandler {
                let action = UIAlertAction(title: actionTitle, style: .default, handler: { _ in actionHandler() })
                alert.addAction(action)
            }
            
            let close = UIAlertAction(title: cancelTitle, style: .cancel, handler: { _ in cancelHandler?() })
            alert.addAction(close)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self?.present(alert, animated: true, completion: presentCompletion)
            }
        }
    }
}
