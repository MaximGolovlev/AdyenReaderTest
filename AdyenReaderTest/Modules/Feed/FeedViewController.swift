//
//  FeedViewController.swift
//  AdyenReaderTest
//
//  Created by Maxim on 14.03.2023.
//

import UIKit


class FeedViewController: UIViewController {
    
    
    var mainContainer: UIStackView = {
        $0.axis = .vertical
        $0.spacing = 20
        return $0
    }(UIStackView())
    
    lazy var loginButton: UIButton = {
        $0.setTitle("Login", for: .normal)
        $0.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    lazy var terminalTransactionButton: UIButton = {
        $0.titleLabel?.lineBreakMode = .byWordWrapping
        $0.setTitle("Make\nTerminal Transaction", for: .normal)
        $0.addTarget(self, action: #selector(makeTerminalTransactionTapped), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    lazy var transactionButton: UIButton = {
        $0.titleLabel?.lineBreakMode = .byWordWrapping
        $0.setTitle("Make\nReader Transaction", for: .normal)
        $0.addTarget(self, action: #selector(makeReaderTransactionTapped), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .systemBackground
        
        configViews()
        refreshViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !Globals.isLoggedIn {
            loginButtonTapped()
        }
    }
    
    func configViews() {
        
        view.addSubview(mainContainer)
        mainContainer.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.left.right.equalToSuperview().inset(20)
        })
        
        mainContainer.addArrangedSubviews([loginButton, terminalTransactionButton, transactionButton])
    }
    
    func refreshViews() {
        
        let loginTitle = Globals.isLoggedIn ? "Logout" : "Login"
        loginButton.setTitle(loginTitle, for: .normal)
        
    }
    
    @objc private func makeReaderTransactionTapped() {
        
        let vc = ReaderViewController()
        present(vc, animated: true)
    }
    
    @objc private func makeTerminalTransactionTapped() {

        let vc = TerminalViewController()
        present(vc, animated: true)
    }
    
    @objc func loginButtonTapped() {
        
        let vc = LoginViewController()
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
        
    }
}
