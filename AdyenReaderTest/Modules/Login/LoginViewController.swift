//
//  LoginViewController.swift
//  AdyenReaderTest
//
//  Created by Maxim on 13.03.2023.
//

import UIKit


class LoginViewController: UIViewController {
    
    var mainContainer: UIStackView = {
        $0.axis = .vertical
        $0.spacing = 20
        return $0
    }(UIStackView())
    
    lazy var environmentSection = SectionView(buttonTitle: "Change Environment", tapHandler: { [weak self] sectionView in
        self?.changeEnvironment(sourceView: sectionView.button)
    })
    
    lazy var tokenSection = SectionView(tapHandler: { [weak self] sectionView in
        self?.refreshToken(environment: LocalStorage.environment)
    })
    
    lazy var restaurantSection = SectionView(tapHandler: { [weak self] sectionView in
        self?.fetchLocations()
    })
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor.systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        
        configViews()
        refreshViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configViews() {
        
        view.addSubview(mainContainer)
        mainContainer.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.left.right.equalToSuperview().inset(20)
        })
        
        mainContainer.addArrangedSubviews([environmentSection, tokenSection, restaurantSection])
    }
    
    func refreshViews() {
        
        let tokenButtonTitle = LocalStorage.token == nil ? "Generate\nToken" : "Refresh\nToken"
        tokenSection.button.setTitle(tokenButtonTitle, for: .normal)
        
        let locationButtonTitle = LocalStorage.token == nil ? "Select\nRestaurant" : "Change\nRestaurant"
        restaurantSection.button.setTitle(locationButtonTitle, for: .normal)
        
        environmentSection.label.text = LocalStorage.environment.url
        tokenSection.label.text = LocalStorage.token
        restaurantSection.label.text = LocalStorage.restaurant?.name
        
        self.navigationItem.rightBarButtonItem?.isEnabled = Globals.isLoggedIn
    }
    
    func changeEnvironment(sourceView: UIView) {
        
        let alert = UIAlertController(title: "Choose Envoronment", message: nil, preferredStyle: .actionSheet)
        
        let allburov = UIAlertAction(title: Environment.allburov.rawValue, style: .default, handler: { _ in
            LocalStorage.environment = .allburov
            self.refreshViews()
        })
        alert.addAction(allburov)
        
        let staging = UIAlertAction(title: Environment.staging.rawValue, style: .default, handler: { _ in
            LocalStorage.environment = .staging
            self.refreshViews()
        })
        alert.addAction(staging)
        
        let production = UIAlertAction(title: Environment.production.rawValue, style: .default, handler: { _ in
            LocalStorage.environment = .production
            self.refreshViews()
        })
        alert.addAction(production)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in

        })
        alert.addAction(cancel)
        
        alert.popoverPresentationController?.sourceView = sourceView
        alert.popoverPresentationController?.sourceRect = sourceView.frame
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func refreshToken(environment: Environment) {
        let login = environment.login
        let password = environment.password
        
        Task {
            do {
                let manager = APIManager.refreshToken(login: login, password: password)
                let response: LoginResponse = try await manager.makeRequest()
                LocalStorage.token = response.token
                self.refreshViews()
            } catch {
                self.showAlert(message: error.localizedDescription)
            }
        }
    }
    
    func fetchLocations() {
        
        Task {
            do {
                let response: AuthResponse = try await APIManager.auth.makeRequest()
                let locations = response.locations
                presentLocationPicker(sourceView: restaurantSection.button, locations: locations)
            } catch {
                self.showAlert(message: error.localizedDescription)
            }
        }
    }
    
    func presentLocationPicker(sourceView: UIView, locations: [Restaurant]) {
        
        let alert = UIAlertController(title: "Choose Restaurant", message: nil, preferredStyle: .actionSheet)
        
        locations.forEach({ location in
            let action = UIAlertAction(title: location.name, style: .default, handler: { _ in
                LocalStorage.restaurant = location
                self.refreshViews()
            })
            alert.addAction(action)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in

        })
        alert.addAction(cancel)
        
        alert.popoverPresentationController?.sourceView = sourceView
        alert.popoverPresentationController?.sourceRect = sourceView.frame
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func doneTapped() {
        dismiss(animated: true)
    }
    
}
